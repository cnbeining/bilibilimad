class Weekly < ActiveRecord::Base
  belongs_to :last, :foreign_key => :parent_id, :class_name => 'Weekly'
  def self.latest
      find :first, :conditions => "wid is not null", :order => '"index" desc'
  end

  def set_name edate
    update_attribute :name, %[#{edate.year % 2000}年#{edate.month}月第#{edate.day / 7 + 1}周]
  end
end
