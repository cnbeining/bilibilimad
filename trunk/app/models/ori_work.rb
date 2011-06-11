class OriWork < ActiveRecord::Base
  establish_connection :bilibili
  set_table_name :works
end
