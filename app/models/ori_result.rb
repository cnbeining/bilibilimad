class OriResult < ActiveRecord::Base
  establish_connection :bilibili
  set_table_name :results
  belongs_to :work, :class_name => "OriWork"
  belongs_to :scan, :class_name => "OriScan"
end
