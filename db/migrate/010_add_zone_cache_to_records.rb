class AddZoneCacheToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :zone_name, :string
    add_index :records, :zone_name
    
    # Update existing records
    Zone.find(:all, :select => 'id, name').each do |z|
      Record.update_all( "zone_name = '#{z.name}'", [ "zone_id = ?", z.id ] )
    end
  end

  def self.down
    remove_column :records, :zone_name
  end
end
