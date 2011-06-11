class KeyUser < ActiveRecord::Base
  establish_connection :user
  belongs_to :key
  validates_uniqueness_of :uname, :scope=>:key_id, :message => 'same'
  validates_presence_of :uname, :message => 'uname is null'
end
