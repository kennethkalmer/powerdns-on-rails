class AddNotesToZones < ActiveRecord::Migration
  def self.up
    add_column :zones, :notes, :text
  end

  def self.down
    remove_column :zones, :notes
  end
end
