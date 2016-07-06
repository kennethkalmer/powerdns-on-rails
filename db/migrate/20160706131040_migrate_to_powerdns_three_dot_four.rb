class MigrateToPowerdnsThreeDotFour < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer    :domain_id
      t.string     :name
      t.string     :type
      t.integer    :modified_at
      t.string     :account
      t.text       :comment,     :limit => 16777215
      t.timestamps
    end
    add_index :comments, :domain_id
    add_index :comments, [:name, :type]
    add_index :comments, [:domain_id, :modified_at]
    
    create_table :cryptokeys do |t|
      t.integer :domain_id
      t.integer :flags
      t.boolean :active
      t.text    :content
      t.timestamps
    end
    add_index :cryptokeys, :domain_id
    
    create_table :domainmetadata do |t|
      t.integer :domain_id
      t.string  :kind
      t.text    :content
      t.timestamps
    end
    add_index :domainmetadata, :domain_id
    
    add_column :records, :disabled,  :boolean, :default => false
    add_column :records, :auth,      :boolean, :default => true
    add_column :records, :ordername, :string
    add_index  :records, [:domain_id, :ordername]
    
    begin
      User.all.each do |u|
        u.confirmed_at = Time.now
        u.save
      end
    rescue
      # let migrations pass on error
    end
    
    begin
      create_table :supermasters do |t|
        t.string  :ip
        t.string  :nameserver
        t.string  :account
        t.timestamps
      end
    rescue
      # let migrations pass with existing powerdns schema
    end
    
    create_table :tsigkeys do |t|
      t.string  :name
      t.string  :algorithm
      t.string  :secret
      t.timestamps
    end
    add_index :tsigkeys, [:name, :algorithm], { unique: true }
    
  end

  def self.down
    drop_table :comments
    drop_table :cryptokeys
    drop_table :domainmetadata
    
    remove_column :records, :disabled
    remove_column :records, :auth
    remove_column :records, :ordername
    remove_index  :records, :column => [:domain_id, :ordername]
    
  end
end
