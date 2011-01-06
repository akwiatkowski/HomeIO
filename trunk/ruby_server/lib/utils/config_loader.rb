#!/usr/bin/ruby1.9.1
#encoding: utf-8

require 'singleton'
require 'yaml'

# Singleton class which load and store config files inself
class ConfigLoader
  include Singleton

  CONFIG_FILES_PATH = "config"
  INPUT_FILES_DIR = "input"

  # Load config if needed, or forced
  def config( type, force = false )
    # convert to symbol
    type = type.to_s.to_sym

    if @@config[ type ].nil? or force == true
      @@config[ type ] = YAML::load_file( File.join(CONFIG_FILES_PATH, "#{type.to_s}.yml") )
    end

    return @@config[ type ]
  end

  # Create hash for all configs
  def initialize
    @@config = Hash.new unless defined? @@config
  end

  # Load other input files
  def load_input( type )
    return YAML::load_file( File.join(CONFIG_FILES_PATH, INPUT_FILES_DIR, "#{type.to_s}.yml") )
  end

end
