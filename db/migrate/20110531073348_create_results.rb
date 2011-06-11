class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.integer :work_id
      t.integer :weekly_id
      t.string :name
      t.integer :click
      t.integer :stow
      t.integer :yb
      t.integer :tj
      t.integer :part
      t.integer :rank
    end
  end

  def self.down
    drop_table :results
  end
end
