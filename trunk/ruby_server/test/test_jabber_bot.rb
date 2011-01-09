#!/usr/bin/ruby1.9.1
#encoding: utf-8

#Encoding.default_internal = "UTF-8"
#Encoding.default_external = "UTF-8"

require './lib/plugins/jabber/jabber_bot.rb'
require './lib/plugins/jabber/jabber_processor.rb'
require 'test/unit'

class TestJabber < Test::Unit::TestCase

  def test_new
    j = JabberBot.instance
    j.start( 'wiatrak_lakie@jabbim.pl', 'antek' )

    loop do
      sleep(30)
    end
  end

  #  def del_test_old
  #    j = JabberBot.new( 'wiatrak_lakie@jabbim.pl', 'antek')
  #    j.start_bot
  #
  #    loop do
  #      sleep(30)
  #    end
  #  end
  #
  #  def del_test_rexml
  #    require "rexml/document"
  #    #file = File.new( "mydoc.xml" )
  #
  #    doc = REXML::Document.new file
  #
  #    puts "**"
  #    puts doc.root.inspect
  #    puts "**"
  #  end

end
