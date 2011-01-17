#!/usr/bin/ruby1.9.1
#encoding: utf-8

require 'rubygems'
require 'singleton'

require './lib/plugins/im/im_command_resolver.rb'
require './lib/plugins/im/im_processor.rb'
require './lib/utils/config_loader.rb'

# Abstract class to all IM comm. classes

class ImBotAbstract
  include Singleton

  # processor class used for resolving commands
  PROCESSOR = ImCommandResolver

  # is bot enabled
  attr_reader :enabled

  # Load config
  def initialize
    @config = ConfigLoader.instance.config( self.class )
    @enabled = @config[:enabled]
  end

  # Bot starter
  # Start only if enabled
  def start
    _start if true == @enabled
  end

  private



end
