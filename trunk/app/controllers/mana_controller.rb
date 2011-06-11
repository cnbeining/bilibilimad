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

end
