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
require 'robustthread'
require 'singleton'
require 'lib/utils/core_classes'

require "lib/communication/im/bots/xmpp4r_bot"
require "lib/communication/im/bots/gadu_bot"

# Load and start IM bots

# XXXXXXXXXXXXXXXXXXXX DELETE DOC XXXXXXXXXXXXXXXXX

#
# reformat it http://rdoc.sourceforge.net/doc/index.html
#
# How bots works:
#
# Bot communication is multilayer:
# 1. Bot object (ex. Xmpp4rBot, GaduBot) has accesor +processor+ which store
#    used first step processor:
#    
# 2. Processor is an object which has method +process_command( msg, from )+
#    to sens processing of command somewhere else, or to process it by self
#    when it is better way. There are 2 possible processors:
#    - +ImCommandResolver+ - direct processor, currenty can be outdated because
#      is not used
#    - +TcpCommandResolver+ - remote processor, use another layers described later
#
#  3. When processor +TcpCommandResolver+ is choosed:
#     Send command via tcp homeio protocol using +SupervisorClient+ to
#     +SupervisorServer+. HomeIO uses special protocol which works by sending
#     command in +Hash+ or +TcpTask+ object.
#
#     Commands '?', 'help', and in soon future 'queue' are executed instantly,
#     others go to +SupervisorQueue+
#
#  4. When +SupervisorQueue+ get IM command it use +ImCommandResolver+ to
#     resolve it. Just like it was not any TCP communication.
#
#     

class ImBots
  include Singleton

  attr_reader :bots

  def initialize
    @config = ConfigLoader.instance.config(self.class)

    require 'lib/communication/im_command_resolver'
    @processor = ImCommandResolver.instance

    @bots = [
      GaduBot.instance,
      Xmpp4rBot.instance,
    ]
  end

  # Start bots
  def start
    @bots.each do |b|
      b.processor = @processor
      b.start
    end
    
    if true == @config[:run_autoupdater]
      require './lib/plugins/im/im_autoupdated_status.rb'
      ImAutoupdatedStatus.instance.run_autoupdater
    end
  end

  # Stop all bots
  def stop
    @bots.each do |b|
      b.stop
    end
  end

  # Show debug information
  def debug
    @bots.each do |b|
      b.debug
    end
  end

end
