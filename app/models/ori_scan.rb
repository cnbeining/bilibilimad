class OriScan < ActiveRecord::Base
  establish_connection :bilibili
  set_table_name :scans
end
