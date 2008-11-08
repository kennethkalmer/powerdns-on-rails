class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.string :name
      t.string :master
      t.integer :last_check
      t.string :type, :default => 'NATIVE'
      t.integer :notified_serial
      t.string :account
      t.integer :ttl, :allow_null => false, :default => 86400

      t.timestamps
    end
    
    add_index :domains, :name
  end

  def self.down
    drop_table :domains
  end
end
