# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "record_templates", :force => true do |t|
    t.integer  "zone_template_id"
    t.integer  "ttl"
    t.string   "record_type"
    t.string   "host",             :default => "@"
    t.integer  "priority"
    t.string   "data"
    t.string   "primary_ns"
    t.string   "contact"
    t.integer  "refresh"
    t.integer  "retry"
    t.integer  "expire"
    t.integer  "minimum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "records", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "ttl"
    t.string   "type"
    t.string   "host",       :default => "@"
    t.integer  "priority"
    t.string   "data"
    t.string   "primary_ns"
    t.string   "contact"
    t.integer  "serial"
    t.integer  "refresh"
    t.integer  "retry"
    t.integer  "expire"
    t.integer  "minimum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["zone_id"], :name => "index_records_on_zone_id"
  add_index "records", ["type"], :name => "index_records_on_type"
  add_index "records", ["host"], :name => "index_records_on_host"

  create_table "zone_templates", :force => true do |t|
    t.string   "name"
    t.integer  "ttl",        :default => 86400
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ttl",        :default => 86400
  end

  add_index "zones", ["name"], :name => "index_zones_on_name"

end
