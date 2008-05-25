class AddDefaultTtlToZone < ActiveRecord::Migration
  def self.up
    add_column :zones, :ttl, :integer, :allow_null => false, :default => 86400
  end

  def self.down
    remove_column :zones, :ttl
  end
end
