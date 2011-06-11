class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.integer :wid
      t.datetime :cdate
      t.string :author
    end
  end

  def self.down
    drop_table :works
  end
end
