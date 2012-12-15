#!/usr/bin/ruby1.9.1
#encoding: utf-8

# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require './lib/metar/metar_code.rb'
require './lib/storage/storage.rb'

class MetarLoggerDbStore < Test::Unit::TestCase
  def test_store
    #good_metar = "2010/08/15 05:00 CXAT 150500Z AUTO 31009KT 04/03 RMK AO1 6PAST HR 3001 P0002 T00370033 50006 "
    #mc = MetarCode.new
    #mc.process(good_metar, 2010, 11)
    #assert_equal true, mc.valid?

    ma = load_some_metars
    ma.each do |m|
      mc = MetarCode.new
      mc.process(m, 2010, 12)
      mc.store
    end
    
    # force flush
    Storage.instance.flush
  end

  private

  def load_some_metars
    # TODO rewrite to load random metar log
    f = File.new("./data/metar_log/EPPO/2010/metar_EPPO_2010_12.log","r")
    ma = f.readlines
    f.close

    puts ma.inspect

    return ma
  end

end
