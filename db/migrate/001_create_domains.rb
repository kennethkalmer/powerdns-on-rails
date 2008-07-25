class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.string :name
      t.integer :ttl, :integer, :allow_null => false, :default => 86400

      t.timestamps
    end
    
    add_index :domains, :name
  end

  def self.down
    drop_table :domains
  end
end
