#!/usr/bin/ruby
#encoding: utf-8

# This file is part of HomeIO.
#
#    HomeIO is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    HomeIO is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

require 'singleton'
require 'yaml'

# Singleton class which load and store config files inself
class ConfigLoader
  include Singleton

  # versioned configs, lower priority
  CONFIG_FILES_PATH = "config"
  # local configs, not versioned, with higher priority, often with password
  CONFIG_LOCAL_FILES_PATH = "config_local"
  # folder to other configs
  INPUT_FILES_DIR = "input"

  # Load config if needed, or forced
  def config( type, force = false )
    # convert to symbol
    type = type.to_s.to_sym

    if @@config[ type ].nil? or force == true
      @@config[ type ] = load_config( type )
    end

    return @@config[ type ]
  end

  # Create hash for all configs
  def initialize
    @@config = Hash.new unless defined? @@config
  end

  # Load other input files
  def load_input( type )
    return  YAML::load_file( File.join(CONFIG_FILES_PATH, INPUT_FILES_DIR, "#{type.to_s}.yml") )
  end

  private

  # Load config, but first local version of config
  def load_config( type )
    begin
      return YAML::load_file( File.join(CONFIG_LOCAL_FILES_PATH, "#{type.to_s}.yml") )
    rescue
      return YAML::load_file( File.join(CONFIG_FILES_PATH, "#{type.to_s}.yml") )
    end
  end

end
