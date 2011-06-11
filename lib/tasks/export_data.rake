#id1 前，default=0; id2 后，default=last.id; pa, 必须有except.yml
namespace :bld do
  desc "Export to yaml"
  task :export => :environment do
    puts time = Time.now
    pa = ENV['pa'] ? "#{BILI_PRO_PATH}#{ENV['pa']}/" : nil
    id1 = ENV['id1'] || (YAML.load(open(File.join "#{Rails.root}/config/last.yml")) rescue 0)
    id2 = ENV['id2'] || OriScan.last.id
    except_ids = (YAML.load open(File.join "#{Rails.root}/config/except.yml") rescue [-1])
    #=====================================================================
    doc = File.new(pa ? pa + "_mad.csv" : "#{Rails.root}/_mad.csv", 'w')
    str = "总分排名,总分,id,投稿时间,标题,投稿人,点击,收藏,硬币,推荐,P\n"
    all_work_ids = OriWork.all(:select => "wid", :conditions => ["status = 1 and wid not in (?) and ac_type_id = 7", except_ids]).collect{|w| w.wid}
    results = Result.stat(id1, id2, except_ids)
    File.open(%[#{Rails.root}/config/_list.yml],"w"){ |io| YAML.dump results.each{|r| r['work'] = r.work}[0...200],io }
    all_work_ids -= results.collect{|r| r.work.wid}
    results.select{|r| r['point'] >= 100 || r['point'] < 0}.each do |r|
        str << %(#{r[:rank]},#{r['point']},)
        str << %(#{r.work.wid},#{r.work.cdate},"#{r.name.gsub(/"/, '""')}","#{r.work.author.gsub(/"/, '""')}",)
        str << %(#{r.click},#{r.stow},#{r.yb},#{r.tj},)
        str << %(#{r.part})
        str << "\n"
    end
    doc.write str
    puts "#{Time.now - time} second complete"
    File.open(%[#{Rails.root}/config/_lost.yml],"w"){ |io| YAML.dump all_work_ids.select{|id| id < OriWork.maximum('wid')},io }
  end
end
