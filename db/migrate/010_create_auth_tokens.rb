class CreateAuthTokens < ActiveRecord::Migration
  def self.up
    create_table :auth_tokens do |t|
      t.references :domain
      t.references :user
      t.string :token, :null => false
      t.text :permissions, :null => false
      t.timestamps
      t.datetime :expires_at, :null => false
    end
  end

  def self.down
    drop_table :auth_tokens
  end
end
