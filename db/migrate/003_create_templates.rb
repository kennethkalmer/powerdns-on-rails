class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :zone_templates do |t|
      t.string :name
      t.integer :ttl, :allow_null => false, :default => 86400
      
      t.timestamps
    end
    
    create_table :record_templates do |t|
      t.integer :zone_template_id
      t.integer :ttl
      t.string :record_type
      t.string :host, :default => '@'
      t.integer :priority
      t.string :data
      t.string :primary_ns
      t.string :contact
      t.integer :refresh
      t.integer :retry
      t.integer :expire
      t.integer :minimum

      t.timestamps
    end
  end

  def self.down
    drop_table :zone_templates
    drop_table :record_templates
  end
end
