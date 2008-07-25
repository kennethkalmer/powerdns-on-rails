class AddZoneOwners < ActiveRecord::Migration
  def self.up
    add_column :domains, :user_id, :integer
  end

  def self.down
    remove_column :domains, :user_id
  end
end
