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
require File.join Dir.pwd, 'lib/utils/adv_log'

# Singleton class which load and store config files in self

class ConfigLoader
  include Singleton

  # configs from repository, lower priority
  CONFIG_FILES_PATH = "config"
  # local configs, not in repository, with higher priority, often with password
  CONFIG_LOCAL_FILES_PATH = "config_local"
  # folder to other configs
  INPUT_FILES_DIR = "input"

  # Create hash for all configs
  def initialize
    @@config = Hash.new unless defined? @@config
  end
  
  # Load YAML config if needed, or forced
  #
  # :call-seq:
  #   config( String class name ) => load config for class
  #   config( Class ) => load config for class, force reload
  #   config( Object instance ) => load config for class
  def config( type, force = false )
    # convert to symbol
    type = AdvLog.instance.class_name( type ).to_sym

    if @@config[ type ].nil? or force == true
      @@config[ type ] = load_config( type )
    end

    return @@config[ type ]
  end

  # Load other input files in YAML format
  #
  # :call-seq:
  #   load_input( String ) =>
  def load_input( type )
    return  YAML::load_file( File.join(CONFIG_FILES_PATH, INPUT_FILES_DIR, "#{type.to_s}.yml") )
  end

  private

  # Load config, but first local version of config
  #
  # :call-seq:
  #   load_config( String )
  #   load_config( Symbol )
  def load_config( type )
    begin
      return YAML::load_file( File.join(CONFIG_LOCAL_FILES_PATH, "#{type.to_s}.yml") )
    rescue
      return YAML::load_file( File.join(CONFIG_FILES_PATH, "#{type.to_s}.yml") )
    end
  end

end
