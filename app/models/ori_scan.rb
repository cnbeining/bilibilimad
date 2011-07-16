class OriScan < ActiveRecord::Base
  establish_connection :bilibili
  set_table_name :scans

  def self.weekly_last_id
    YAML.load(open(File.join "#{Rails.root}/config/last.yml")) rescue 0
  end
end
