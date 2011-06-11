class Key < ActiveRecord::Base
  establish_connection :user
  has_many :key_users
end
