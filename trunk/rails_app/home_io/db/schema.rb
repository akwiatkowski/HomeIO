# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110206215251) do

  create_table "cities", :force => true do |t|
    t.string  "name",                                   :null => false
    t.string  "country",                                :null => false
    t.string  "metar"
    t.float   "lat",                                    :null => false
    t.float   "lon",                                    :null => false
    t.float   "calculated_distance"
    t.boolean "logged_metar",        :default => false, :null => false
    t.boolean "logged_weather",      :default => false, :null => false
  end

  add_index "cities", ["lat", "lon"], :name => "index_cities_on_lat_and_lon", :unique => true
  add_index "cities", ["name", "country"], :name => "index_cities_on_name_and_country", :unique => true

  create_table "meas_archives", :force => true do |t|
    t.datetime "time_from",    :null => false
    t.datetime "time_to",      :null => false
    t.float    "value",        :null => false
    t.integer  "meas_type_id"
  end

  add_index "meas_archives", ["meas_type_id", "time_from"], :name => "index_meas_archives_on_meas_type_id_and_time_from", :unique => true

  create_table "meas_types", :force => true do |t|
    t.string   "type",       :limit => 16, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                              :null => false
    t.string   "email",                              :null => false
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "weather_archives", :force => true do |t|
    t.datetime "time_from",           :null => false
    t.datetime "time_to",             :null => false
    t.float    "temperature"
    t.float    "wind"
    t.float    "pressure"
    t.float    "rain"
    t.float    "snow"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "city_id"
    t.integer  "weather_provider_id"
  end

  add_index "weather_archives", ["weather_provider_id", "city_id", "time_from", "time_to"], :name => "weather_archives_index", :unique => true

  create_table "weather_metar_archives", :force => true do |t|
    t.datetime "time_from",   :null => false
    t.datetime "time_to",     :null => false
    t.float    "temperature"
    t.float    "wind"
    t.float    "pressure"
    t.integer  "rain_metar"
    t.integer  "snow_metar"
    t.string   "raw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "city_id"
  end

  add_index "weather_metar_archives", ["time_from", "city_id"], :name => "weather_metar_archives_raw_city_uniq_index", :unique => true
  add_index "weather_metar_archives", ["time_from", "raw"], :name => "weather_metar_archives_raw_uniq_index", :unique => true

  create_table "weather_providers", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weather_providers", ["name"], :name => "index_weather_providers_on_name", :unique => true

end
