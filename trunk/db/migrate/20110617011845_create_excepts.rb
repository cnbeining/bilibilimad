class CreateExcepts < ActiveRecord::Migration
  def self.up
    create_table :excepts do |t|
      t.integer :avid
    end
  end

  def self.down
    drop_table :excepts
  end
end
