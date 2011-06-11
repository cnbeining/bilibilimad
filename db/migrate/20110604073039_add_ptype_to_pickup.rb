class AddPtypeToPickup < ActiveRecord::Migration
  def self.up
    add_column :pickups, :ptype, :integer
  end

  def self.down
    remove_column :pickups, :ptype
  end
end
