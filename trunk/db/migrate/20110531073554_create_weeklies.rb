class CreateWeeklies < ActiveRecord::Migration
  def self.up
    create_table :weeklies do |t|
      t.integer :wid
      t.string :name
      t.integer :parent_id
      t.integer :index
      t.integer :rank_from
      t.float :rule
    end
  end

  def self.down
    drop_table :weeklies
  end
end
