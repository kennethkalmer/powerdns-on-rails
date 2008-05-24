class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string :name

      t.timestamps
    end
    
    add_index :zones, :name
  end

  def self.down
    drop_table :zones
  end
end
