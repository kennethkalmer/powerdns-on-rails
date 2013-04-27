class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :domain_id, :null => false
      t.string :name, :null => false
      t.string :type, :null => false
      t.string :content, :null => false
      t.integer :ttl, :null => false
      t.integer :prio
      t.integer :change_date, :null => true 
      
      t.timestamps :null => true
    end
    
    add_index :records, :domain_id
    add_index :records, :name
    add_index :records, [ :name, :type ]
  end

  def self.down
    drop_table :records
  end
end
