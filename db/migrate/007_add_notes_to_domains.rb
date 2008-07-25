class AddNotesToDomains < ActiveRecord::Migration
  def self.up
    add_column :domains, :notes, :text
  end

  def self.down
    remove_column :domains, :notes
  end
end
