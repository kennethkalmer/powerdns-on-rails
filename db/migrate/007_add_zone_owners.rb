class AddZoneOwners < ActiveRecord::Migration
  def self.up
    add_column :zones, :user_id, :integer
  end

  def self.down
    remove_column :zones, :user_id
  end
end
