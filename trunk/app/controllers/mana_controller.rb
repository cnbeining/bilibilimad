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

  def data
    @weekly = params[:id] ? Weekly.find(params[:id]) : Weekly.last
    @results = Result.find_all_by_weekly_id @weekly.id, :order => "rank", :limit => 100
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
