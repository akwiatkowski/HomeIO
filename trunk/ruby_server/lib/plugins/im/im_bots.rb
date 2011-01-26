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
require './lib/utils/core_classes.rb'
Dir["./lib/plugins/im/bots/*.rb"].each {|file| require file }

# Load and start IM bots

class ImBots
  include Singleton

  attr_reader :bots

  # there are 2 resolvers
  # direct loads many classes and execute commands now
  COMMAND_RESOLVER_DIRECT = :direct
  # via tcp uses HomeIO task based tcp protocol for all queries
  COMMAND_RESOLVER_VIA_TCP = :via_tcp

  #COMMAND_RESOLVER = COMMAND_RESOLVER_DIRECT
  COMMAND_RESOLVER = COMMAND_RESOLVER_VIA_TCP

  def initialize
    @config = ConfigLoader.instance.config( self.class )

    # commands resolver
    if COMMAND_RESOLVER_DIRECT == COMMAND_RESOLVER
      require './lib/comms/im_command_resolver.rb'
      @processor = ImCommandResolver.instance
    end
    if COMMAND_RESOLVER_VIA_TCP == COMMAND_RESOLVER
      require './lib/comms/tcp_command_resolver.rb'
      @processor = TcpCommandResolver.instance
    end

    @bots = [
      #Jabber4rBot.instance, # errors
      GaduBot.instance,
      Xmpp4rBot.instance,
    ]
  end

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
end
