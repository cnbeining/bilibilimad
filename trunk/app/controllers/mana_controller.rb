class ManaController < ApplicationController
  before_filter :correct_bili_name?, :limit_bili_users
  layout "need_bili_name"

  def index

  end

  def temp_data
    YAML::add_private_type(Result.rule.to_s)
    YAML::add_private_type(Work.to_s)
    @stats = YAML.load(open("#{Rails.root}/config/_list.yml"))
    @stats.each{|s| s.work = s[:work]}
  end

  def realtime
     if params[:id]
       require 'net/http'
       Net::HTTP.version_1_2
       ids = params[:id].split(',')
       weekly_last_id = OriScan.weekly_last_id
       ori_works = OriWork.all :conditions => ["wid in (?)", ids]
       ori_results = OriResult.all :conditions => ["scan_id = ? and work_id in (?)", weekly_last_id, ori_works.collect(&:id)]
       @new_results = {}
       http = Net::HTTP.start(BILI_PATH)
       ori_works.each do |work|
         url = "/plus/count.php?papa=yes&aid=#{work.wid}"
         r = http.get(url, {'Cookie' => %[DedeID=#{work.wid}]})
         rary = r.body.split('\').innerHTML=')
	       click = rary[1].to_i; stow = rary[2].split("'")[1].to_i; yb = rary[3].to_i; tj = rary[4].split("'")[1].to_i
         @new_results[work.wid] = Result.rule.new :click => click, :stow => stow, :part => work.part_count, :yb => yb, :tj => tj, :name => work.name
         if last_r = ori_results.detect{|orr| orr.work_id == work.id}
           @new_results[work.wid].click -= last_r.clicks
           @new_results[work.wid].stow -= last_r.stows
           @new_results[work.wid].yb -= last_r.yb
           @new_results[work.wid].tj -= last_r.tj
         end
       end
     end
  end

  def data
    @weekly = params[:id] ? Weekly.find(params[:id]) : Weekly.last
    @results = Result.rule(@weekly.rule).find_all_by_weekly_id @weekly.id, :order => "rank", :limit => 100
    @latest = Weekly.last
  end

  def excepts
    @excepts = Except.all :order => "avid desc"
    @works = OriWork.all :conditions => ["wid in (?)", @excepts.collect(&:avid)]
  end

  def add_excepts
    ids = params[:except][:ids].split(',')
    ids.each do |avid|
      Except.create :avid => avid
    end
    redirect_to :action => :excepts
  end

  def delete_except
    Except.destroy params[:id]
    redirect_to :action => :excepts
  end

  #pickup
  def list_pickups

  end

  def new_pickups

  end

  def create_pickup

  end

  def update_pickups

  end

  def delete_pickup

  end
end
