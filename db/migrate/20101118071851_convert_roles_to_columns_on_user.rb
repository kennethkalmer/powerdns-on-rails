class ConvertRolesToColumnsOnUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :admin, :default => false
      t.boolean :auth_tokens, :default => false
    end

    User.reset_column_information

    User.send( :has_and_belongs_to_many, :roles )

    User.all.each do |user|
      user.roles.each do |role|
        p [ :role, user.login, role.name ]
        user[:admin] = true if role.name == 'admin'
        user[:auth_tokens] = true if role.name == 'auth_token'
        user.save
      end
    end

    drop_table :roles
    drop_table :roles_users
  end

  def self.down
    create_table "roles", :force => true do |t|
      t.string "name"
    end

    create_table "roles_users", :id => false, :force => true do |t|
      t.integer "role_id"
      t.integer "user_id"
    end

    add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
    add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

    User.send( :has_and_belongs_to_many, :roles )

    admin = Role.create!( :name => 'admin' )
    owner = Role.create!( :name => 'owner' )
    token = Role.create!( :name => 'auth_token')

    User.all.each do |user|
      user.roles << admin if user.admin?
      user.roles << token if user.auth_tokens?
      user.roles << owner if !user.admin? && !user.auth_tokens?
      user.save
    end

    change_table :users do |t|
      t.drop :admin, :auth_tokens
    end
  end
end
