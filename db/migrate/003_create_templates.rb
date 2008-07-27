class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :zone_templates do |t|
      t.string :name
      t.integer :ttl, :allow_null => false, :default => 86400
      
      t.timestamps
    end
    
    create_table :record_templates do |t|
      t.integer :zone_template_id
      t.string :name
      t.string :record_type, :null => false
      t.string :content, :null => false
      t.integer :ttl, :null => false
      t.integer :prio

      t.timestamps
    end
  end

  def self.down
    drop_table :zone_templates
    drop_table :record_templates
  end
end
