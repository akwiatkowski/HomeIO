# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111210132450) do

  create_table "action_events", :force => true do |t|
    t.datetime "time",                              :null => false
    t.text     "other_info"
    t.boolean  "error_status",   :default => false, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "action_type_id"
    t.integer  "user_id"
    t.integer  "overseer_id"
  end

  create_table "action_types", :force => true do |t|
    t.string   "name",       :limit => 64, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "action_types", ["name"], :name => "index_action_types_on_name", :unique => true

  create_table "action_types_users", :force => true do |t|
    t.integer "action_type_id"
    t.integer "user_id"
  end

  add_index "action_types_users", ["action_type_id", "user_id"], :name => "index_action_types_users_on_action_type_id_and_user_id", :unique => true

# Could not dump table "cities" because of following StandardError
#   Unknown type 'bool' for column 'logged_metar'

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "job_class"
    t.integer  "progress",   :default => 0, :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "home_archive_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "home_archives", :force => true do |t|
    t.datetime "time"
    t.float    "value"
    t.integer  "user_id"
    t.integer  "home_archive_type_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "meas_archives", :force => true do |t|
    t.datetime "time_from",                                                  :null => false
    t.datetime "time_to",                                                    :null => false
    t.decimal  "_time_from_ms", :precision => 3, :scale => 0, :default => 0, :null => false
    t.decimal  "_time_to_ms",   :precision => 3, :scale => 0, :default => 0, :null => false
    t.float    "value",                                                      :null => false
    t.integer  "raw"
    t.integer  "meas_type_id"
  end

  add_index "meas_archives", ["meas_type_id", "time_from"], :name => "meas_archive_meat_type_time_index2", :unique => true

  create_table "meas_type_groups", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.string   "unit",       :default => "", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.float    "y_min"
    t.float    "y_max"
    t.float    "y_interval"
  end

  create_table "meas_type_groups_meas_types", :id => false, :force => true do |t|
    t.integer "meas_type_id",       :null => false
    t.integer "meas_type_group_id", :null => false
  end

  create_table "meas_types", :force => true do |t|
    t.string   "name",       :limit => 64,                  :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "unit",       :limit => 32, :default => "?", :null => false
  end

  add_index "meas_types", ["name"], :name => "index_meas_types_on_name", :unique => true

  create_table "memos", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "overseer_parameters", :force => true do |t|
    t.integer  "overseer_id"
    t.string   "key",         :null => false
    t.string   "value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "overseers", :force => true do |t|
    t.string   "name",                          :null => false
    t.string   "klass",                         :null => false
    t.boolean  "active",     :default => false, :null => false
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "hit_count",  :default => 0,     :null => false
    t.datetime "last_hit"
  end

  add_index "overseers", ["name"], :name => "index_overseers_on_name", :unique => true

  create_table "user_tasks", :force => true do |t|
    t.integer "user_id"
    t.integer "delayed_job_id"
    t.text    "params"
    t.string  "klass"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "admin",                  :default => false, :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "weather_archives", :force => true do |t|
    t.datetime "time_from",           :null => false
    t.datetime "time_to",             :null => false
    t.float    "temperature"
    t.float    "wind"
    t.float    "pressure"
    t.float    "rain"
    t.float    "snow"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
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
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "city_id"
  end

  add_index "weather_metar_archives", ["time_from", "city_id"], :name => "weather_metar_archives_raw_city_uniq_index", :unique => true
  add_index "weather_metar_archives", ["time_from", "raw"], :name => "weather_metar_archives_raw_uniq_index", :unique => true

  create_table "weather_providers", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weather_providers", ["name"], :name => "index_weather_providers_on_name", :unique => true

end
