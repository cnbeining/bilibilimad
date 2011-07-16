class Result < ActiveRecord::Base
  belongs_to :work
  belongs_to :weekly

  def self.rule version = RULE
    eval("Rule::R#{(version * 10).to_i}")
  end

  #是否长期
  def is_changqi?
    if weekly_id
      Result.count(:include => :weekly,
        :conditions => ["rank <= weeklies.rank_from and results.work_id = ? and weeklies.id <= ?", work_id, weekly_id
        ]) > 2
    else
      Result.count(:include => :weekly,
        :conditions => ["rank <= weeklies.rank_from and results.work_id = ?", work_id
        ]) >= 2
    end
  end

    #周刊统计数据
  def self.stat id1, id2, except_ids=[-1]
    time = Time.now
    puts "*reading data..."
    results1 = OriResult.all :include => :work,
                           :conditions => ["works.ac_type_id = 7 and results.scan_id = ? and works.status = 1", id1]
    results2 = OriResult.all :include => :work,
                           :conditions => ["works.ac_type_id = 7 and results.scan_id = ? and works.status = 1 and works.wid not in (?)", id2, except_ids]
    puts "#{Time.now - time} seconds passed.."
    results = {}
    results2.each do |r2|
      results[r2.work.wid] = Result.rule.new :click => r2.clicks, :stow => r2.stows, :yb => r2.yb, :tj => r2.tj,
                                                      :name => r2.work.name, :part => r2.work.part_count
      results[r2.work.wid].work = Work.find_by_wid(r2.work.wid) || Work.new(:wid => r2.work.wid, :cdate => r2.work.cdate, :author => r2.work.author_name )
    end
    unless results1.empty?
      results1.each do |r1|
        if results[r1.work.wid]
          results[r1.work.wid].click -= r1.clicks
          results[r1.work.wid].stow -= r1.stows.to_i
          results[r1.work.wid].tj -= r1.tj.to_i
          results[r1.work.wid].yb -= r1.yb.to_i
          results[r1.work.wid][:old] = true
        end
      end
      #删除错误数据
      last_wid = OriResult.maximum("works.wid", :include => :work, :conditions => ["scan_id = ?", id1]).to_i
      results_b = results.select{|i, r| !r[:old] && r.work.wid <= last_wid - 5000 }
      results_b.each{|i, r| results.delete(i)}
      results_b1 = results.select{|i, r| !r[:old] && r.work.wid <= last_wid }
      check_results = OriResult.all(:select => "works.wid", :include => :work,
                                  :conditions => ["wid in (?) and scan_id < ? and clicks > 500", results_b1.collect{|i, r| r.work.wid}, id1]
      ).collect{|r| r.work.wid}.uniq
      results_c = results_b1.select{|i, r| check_results.include?(r.work.wid)}
      File.open(%[#{Rails.root}/config/_lost_last.yml],"w"){ |io| YAML.dump results_b.collect{|r| r.last} + results_c.collect{|r| r.last},io }
      results_c.each{|i, r| results.delete(i)}
    end
    puts "*computing..." #计算分数
    results.values.each{|r| r[:point] = r.get_ranking_point}
    c_rank = nil
    l_id = nil
    #Point序
    results.values.sort_by{|r| r[:point]}.reverse.each_with_index do |r, i|
      c_rank = i + 1 if i == 0 || results[r.work.wid][:point] != results[l_id][:point]
      l_id = r.work.wid
      results[r.work.wid][:rank] = c_rank
    end
    puts "compute over.(#{Time.now - time} sec.)"
    results.values.sort_by{|r| r[:rank]}
  end
end
