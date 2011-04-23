#!/usr/bin/ruby
#encoding: utf-8

# HomeIO - home control system.
# Copyright (C) 2011 Aleksander Kwiatkowski
#
# This file is part of HomeIO.
#
# HomeIO is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HomeIO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HomeIO.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'foreigner'

# Create standard DB scheme

class ActiveRecordInitMigration < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base. transaction do
      create_table :cities do |t|
        t.column :name, :string, :null => false
        t.column :country, :string, :null => false
        t.column :metar, :string, :null => true
        t.column :lat, :float, :null => false
        t.column :lon, :float, :null => false
        # from predefined location
        t.column :calculated_distance, :float, :null => true
        # has metar records logged, used for searching data
        t.column :logged_metar, :bool, :null => false, :default => false
        # has weather records logged, used for searching data
        t.column :logged_weather, :bool, :null => false, :default => false
      end

      # MEASUREMENTS
      create_table :meas_types do |t|
        t.column :name, :string, :limit => 64, :null => false
        t.timestamps
      end

      create_table :meas_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false
        t.column :_time_from_ms, :decimal, :null => false, :default => 0, :precision => 3
        t.column :_time_to_ms, :decimal, :null => false, :default => 0, :precision => 3
        t.column :value, :float, :null => false
        # raw value from uC
        t.column :raw, :integer, :null => true

        t.references :meas_type
      end


      # ACTIONS
      create_table :action_types do |t|
        t.column :name, :string, :limit => 64, :null => false
        t.timestamps
      end

      create_table :action_events do |t|
        t.column :time, :datetime, :null => false
        t.column :other_info, :text, :null => true
        t.column :error_status, :boolean, :null => false, :default => false
        t.timestamps

        t.references :action_type
        # when rails application add table 'users' and user execute actions
        t.references :user
      end

      # actions which can be executed by user
      create_table :action_types_users do |t|
        t.references :action_type
        t.references :user
      end

      # WEATHER
      create_table :weather_providers do |t|
        t.column :name, :string, :null => false
        t.timestamps
      end

      create_table :weather_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false

        t.column :temperature, :float, :null => true
        t.column :wind, :float, :null => true
        t.column :pressure, :float, :null => true
        t.column :rain, :float, :null => true
        t.column :snow, :float, :null => true
      
        t.timestamps
        t.references :city
        t.references :weather_provider
      end

      create_table :weather_metar_archives do |t|
        t.column :time_from, :datetime, :null => false
        t.column :time_to, :datetime, :null => false

        t.column :temperature, :float, :null => true
        t.column :wind, :float, :null => true
        t.column :pressure, :float, :null => true
        t.column :rain_metar, :integer, :null => true
        t.column :snow_metar, :integer, :null => true
        t.column :raw, :string, :null => true, :limit => 255

        t.timestamps
        t.references :city
      end

      # indexes
      add_index :cities, [:lat, :lon], :unique => true
      add_index :cities, [:name, :country], :unique => true
      # meas
      add_index :meas_types, [:name], :unique => true
      add_index :meas_archives, [:meas_type_id, :time_from, :_time_from_ms], :unique => true, :name => 'meas_archive_meat_type_time_index'
      # actions
      add_index :action_types, [:name], :unique => true
      add_index :action_types_users, [:action_type_id, :user_id], :unique => true
      # weather
      add_index :weather_archives, [:weather_provider_id, :city_id, :time_from, :time_to], :unique => true, :name => 'weather_archives_index'
      # weather providers
      add_index :weather_providers, [:name], :unique => true
      # metar
      add_index :weather_metar_archives, [:time_from, :raw], :unique => true, :name => 'weather_metar_archives_raw_uniq_index'
      add_index :weather_metar_archives, [:time_from, :city_id], :unique => true, :name => 'weather_metar_archives_raw_city_uniq_index'

      # foreign key
      add_foreign_key :meas_archives, :meas_types, :dependent => :restrict
      add_foreign_key :action_events, :action_types, :dependent => :restrict

      add_foreign_key :weather_archives, :cities, :dependent => :restrict
      add_foreign_key :weather_archives, :weather_providers, :dependent => :restrict
      add_foreign_key :weather_metar_archives, :cities, :dependent => :restrict

    end
  end

  def self.down
    remove_foreign_key :weather_archives, :cities
    remove_foreign_key :weather_metar_archives, :cities
    remove_foreign_key :meas_archives, :meas_types
    remove_foreign_key :action_events, :action_types
    remove_foreign_key :weather_archives, :weather_providers

    drop_table :meas_archives
    drop_table :action_events
    drop_table :weather_archives
    drop_table :weather_metar_archives

    drop_table :action_types
    drop_table :action_types_users

    drop_table :cities
    drop_table :meas_types
    drop_table :weather_providers
  end
end
