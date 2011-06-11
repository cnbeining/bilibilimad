class Weekly < ActiveRecord::Base
  belongs_to :last, :foreign_key => :parent_id, :class_name => 'Weekly'
  def self.latest
      find :first, :conditions => "wid is not null", :order => '"index" desc'
  end
end
