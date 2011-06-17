class Except < ActiveRecord::Base
  validates_uniqueness_of :avid, :message => 'same'

  def self.all_avid
    all.collect(&:avid)
  end
end
