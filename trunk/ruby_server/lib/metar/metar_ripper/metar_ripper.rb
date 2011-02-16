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

require 'lib/utils/core_classes'
require 'singleton'

# better way to load all files from dir
require_files_from_directory("lib/metar/metar_ripper/")


# Rips raw metar from various sites

class MetarRipper
  include Singleton

  # some providers has slow webpages, turing them off will reduce time cost
  USE_ALSO_SLOW_PROVIDERS = false

  attr_reader :klasses

  def initialize
    @klasses = [
      MetarRipperNoaa, # superfast <0.5s
      MetarRipperAviationWeather, # fast 0.4-1s
      MetarRipperWunderground, # not fast 1-2s
    ]

    if USE_ALSO_SLOW_PROVIDERS
      @klasses << MetarRipperAllMetSat # slowest, 4s
    end

  end

  def fetch(city)
    codes = Array.new
    @klasses.each do |k|
      #puts k.new.a
      codes << k.new.fetch(city)
    end

    # return uniq and not blank
    codes = codes.select { |c| not '' == c.to_s.strip }.uniq
    return codes
  end


end
