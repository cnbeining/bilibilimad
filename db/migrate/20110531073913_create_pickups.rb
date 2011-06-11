class CreatePickups < ActiveRecord::Migration
  def self.up
    create_table :pickups do |t|
      t.integer :wid
      t.integer :weekly_id
    end
  end

  def self.down
    drop_table :pickups
  end
end
