class UsersCanOwnZoneTemplates < ActiveRecord::Migration
  def self.up
    add_column :zone_templates, :user_id, :integer
  end

  def self.down
    remove_column :zone_templates, :user_id
  end
end
