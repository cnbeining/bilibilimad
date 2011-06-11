class ResultController < ApplicationController
  def one
    result = Result.find_by_score_rank_and_weekly_id params[:rank], params[:id]
    work =Work.find_by_wid result.wid, :select => "wid, cdate, pic_path"
    last_score_rank = result.last_score_rank
    is_changqi = result.is_changqi?
    respond_to do |format|
      format.yaml { render :text => [result, work, last_score_rank, is_changqi].to_yaml, :content_type => 'text/yaml'}
      #format.xml { render :xml => result.to_xml }
    end
  end

  def top
    weekly = Weekly.find params[:id]
    last_weekly = weekly.last
    pickup_wids = Pickup.find_all_by_weekly_id_and_ptype(params[:id], 1).collect(&:wid)
	pickup_self_wids = Pickup.find_all_by_weekly_id_and_ptype(params[:id], 2).collect(&:wid)
    results = Result.rule.all :select => "w.wid, w.author, w.cdate, r.*", :joins => "r join works w on w.id = r.work_id",
                         :limit => params[:num], :order => "rank", :conditions => ["weekly_id = ?", params[:id]]
    results += Result.rule.all :select => "w.wid, w.author, w.cdate, r.*", :joins => "r join works w on w.id = r.work_id",
                         :conditions => ["weekly_id = ? and w.wid in (?)", params[:id], pickup_wids]
	results_self = Result.rule.all :select => "w.wid, w.author, w.cdate, r.*", :joins => "r join works w on w.id = r.work_id",
                         :conditions => ["weekly_id = ? and w.wid in (?)", params[:id], pickup_self_wids]
    results.each{|r| r[:score] = r.point}
    wids = results.collect(&:wid)
    last_ranks = {}
    if last_weekly
      last_last = last_weekly.last
      wids.select{|w| w > last_weekly.wid}.each{|w| last_ranks[w] = 0; wids.delete w }
      last_ranks.merge! Result.sum('rank', :include => :work,
            :conditions =>["weekly_id = ? and works.wid in (?)", last_weekly.id, wids],
            :group => "works.wid")
      #WeeklyExcept.all(:conditions =>["weekly_id = ? and wid in (?)", last_weekly.id, wids]).each{|we| last_ranks[we] = -1}
      Result.count( :include => [:weekly, :work],
              :conditions => ['weeklies."index" < ? and works.wid in (?)', last_weekly.index, wids.reject{|w| last_ranks[w] }],
              :group => "works.wid").each{|k, v| last_ranks[k] = -222}
      wids.each do |w|
        last_ranks[w] ||= 0
        last_ranks[w] = nil if last_ranks[w] == -222
      end
      #results.reject{|r| last_ranks.keys.include? r.wid }.each{|r| last_ranks[r.wid] = r.new_rank_check }
      #is_changqi_hash = WeeklyResult.count('weekly_results.wid', :include => 'weekly',
      #    :conditions => ["score_rank <= weeklies.rank_from and weekly_results.wid in (?) and weeklies.id < ?", wids.reject{|w| last_ranks[w] #&&  last_ranks[w].zero? }, params[:id]],
     #     :group => 'weekly_results.wid')
    else
      wids.each{|w| last_ranks[w] = 0 }
      is_changqi_hash = {}
    end
    respond_to do |format|
      format.yaml { render :text => [results, last_ranks, is_changqi_hash, results_self].to_yaml, :content_type => 'text/yaml'}
      #format.xml { render :xml => results.to_xml }
    end
  end
end
