class ManaController < ApplicationController
  before_filter :correct_bili_name?, :limit_bili_users
  layout "need_bili_name"

  def index

  end

  def temp_data
    YAML::add_private_type(Result.rule.to_s)
    YAML::add_private_type(Work.to_s)
    @stats = YAML.load(open("#{RAILS_ROOT}/config/_list.yml"))
    @stats.each{|s| s.work = s[:work]}
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

end
