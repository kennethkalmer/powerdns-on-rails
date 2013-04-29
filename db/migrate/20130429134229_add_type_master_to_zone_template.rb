class AddTypeMasterToZoneTemplate < ActiveRecord::Migration
  def change
    add_column :zone_templates, :type, :string, :default => 'NATIVE'
    add_column :zone_templates, :master, :string
  end
end
 
