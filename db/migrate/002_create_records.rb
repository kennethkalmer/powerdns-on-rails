class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :zone_id
      t.integer :ttl
      t.string :type
      t.string :host, :default => '@'
      t.integer :priority
      t.string :data
      t.string :primary_ns
      t.string :contact
      t.integer :serial
      t.integer :refresh
      t.integer :retry
      t.integer :expire
      t.integer :minimum

      t.timestamps
    end
    
    add_index :records, :zone_id
    add_index :records, :type
    add_index :records, :host
  end

  def self.down
    drop_table :records
  end
end
