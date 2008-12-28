class CreateMacros < ActiveRecord::Migration
  def self.up
    create_table :macros do |t|
      t.string :name, :description
      t.references :user
      t.boolean :active, :default => false
      
      t.timestamps
    end

    create_table :macro_steps do |t|
      t.references :macro
      t.string :action, :record_type, :name, :content
      t.integer :ttl, :prio, :position
      t.boolean :active, :default => true
      t.string :note
      
      t.timestamps
    end
    
  end

  def self.down
    drop_table :macros
    drop_table :macro_steps
  end
end

