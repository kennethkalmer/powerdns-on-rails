# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "record_templates", :force => true do |t|
    t.integer  "zone_template_id", :limit => 11
    t.integer  "ttl",              :limit => 11
    t.string   "record_type"
    t.string   "host",                           :default => "@"
    t.integer  "priority",         :limit => 11
    t.string   "data"
    t.string   "primary_ns"
    t.string   "contact"
    t.integer  "refresh",          :limit => 11
    t.integer  "retry",            :limit => 11
    t.integer  "expire",           :limit => 11
    t.integer  "minimum",          :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "records", :force => true do |t|
    t.integer  "zone_id",    :limit => 11
    t.integer  "ttl",        :limit => 11
    t.string   "type"
    t.string   "host",                     :default => "@"
    t.integer  "priority",   :limit => 11
    t.string   "data"
    t.string   "primary_ns"
    t.string   "contact"
    t.integer  "serial",     :limit => 11
    t.integer  "refresh",    :limit => 11
    t.integer  "retry",      :limit => 11
    t.integer  "expire",     :limit => 11
    t.integer  "minimum",    :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["zone_id"], :name => "index_records_on_zone_id"
  add_index "records", ["type"], :name => "index_records_on_type"
  add_index "records", ["host"], :name => "index_records_on_host"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :limit => 11
    t.integer "user_id", :limit => 11
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
  end

  create_table "zone_templates", :force => true do |t|
    t.string   "name"
    t.integer  "ttl",        :limit => 11, :default => 86400
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ttl",        :limit => 11, :default => 86400
    t.integer  "user_id",    :limit => 11
  end

  add_index "zones", ["name"], :name => "index_zones_on_name"

end
