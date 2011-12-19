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


require 'singleton'
require 'yaml'
require File.join Dir.pwd, 'lib/utils/config_loader'
require File.join Dir.pwd, 'lib/utils/adv_log'

# Store and periodically saves development data
# At start reload from stored file

class DevInfo
  include Singleton

  # Load previously stored dev info
  def initialize
    # loaded from config file
    @config              = ConfigLoader.instance.config(self.class)
    @DEV_INFO_STORE_FILE = @config[:store_file_path]
    @AUTOSAVE_INTERVAL   = @config[:autosave_interval]

    self_load
    new_thread
  end

  # Increment key
  #
  # :call-seq:
  #   inc( Class, Symbol )
  #   inc( String class name, Symbol )
  #   inc( Object instance, Symbol )
  #   inc( Class, String )
  #   inc( String class name, String )
  #   inc( Object instance, String )
  def inc(klass, key)
    # prefer symbol
    klass = AdvLog.instance.class_name(klass).to_sym
    key   = key.to_s.to_sym

    if @dev_info[klass].nil? or @dev_info[klass][key].nil?
      # need to create first
      create_empty_fixnum(klass, key)
    end

    @dev_info[klass][key] += 1
    return @dev_info[klass][key]
  end

  # Get data as hash
  #
  # :call-seq:
  #   [ Class ]
  #   [ String ]
  #   [ Object instance ]
  def [](klass)
    klass = AdvLog.instance.class_name(klass).to_sym

    if @dev_info[klass].nil?
      @dev_info[klass] = Hash.new
    end

    return @dev_info[klass]
  end

  # Force saving
  def force_save
    self_save
  end

  # Force loading
  def force_load
    self_load
  end

  # Filename and path of dev info file
  def file_name
    return @DEV_INFO_STORE_FILE
  end

  # Autosave interval
  def autosave_interval
    return @AUTOSAVE_INTERVAL
  end

  private

  # Create zero value entry
  #
  # :call-seq:
  #   create_empty_fixnum( Symbol, Symbol )
  def create_empty_fixnum(klass, key)
    if @dev_info[klass].nil?
      @dev_info[klass] = Hash.new
    end

    @dev_info[klass][key] = 0
  end

  # Load info
  def self_load
    if File.exist?(@DEV_INFO_STORE_FILE)
      @dev_info = YAML::load_file(@DEV_INFO_STORE_FILE)
      # sometime there is error - blank file
      @dev_info = Hash.new if not @dev_info.kind_of?(Hash)

      # increment load count
      inc(self.class, :load_count)
    else
      @dev_info                     = Hash.new

      # set creation time
      self[self.class][:created_at] = Time.now
    end
  end

  # Save info
  def self_save
    File.open(@DEV_INFO_STORE_FILE, 'w') do |out|
      YAML.dump(@dev_info, out)
    end

    inc(self.class, :save_count)
    self[self.class][:last_save] = Time.now
  end

  # Thread for saving every interval
  def new_thread
    # new thread
    Thread.new do
      loop do
        # wait interval
        sleep @AUTOSAVE_INTERVAL
        Thread.exclusive do
          # saving should be done exclusive to not lost data if server crash
          self_save
        end

        inc(self.class, :autosave_count)
      end
    end
  end

end
