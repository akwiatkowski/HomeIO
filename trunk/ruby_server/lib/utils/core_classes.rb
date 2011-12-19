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

# Load additions to Ruby standard classes

require File.join Dir.pwd, 'lib/utils/object'
require File.join Dir.pwd, 'lib/utils/date'
require File.join Dir.pwd, 'lib/utils/string'
require File.join Dir.pwd, 'lib/utils/time'
require File.join Dir.pwd, 'lib/utils/nil_class'
require File.join Dir.pwd, 'lib/utils/proc'
require File.join Dir.pwd, 'lib/utils/array'

# Require all files from path (ex. "lib/metar/metar_ripper/")
#
# :call-seq:
#   require_files_from_directory( String path ) => require all .rb files from path
#   require_files_from_directory( String path, String mask ) => require all files using mask from path
def require_files_from_directory(path, mask = "*.rb")
  Dir["./#{path}#{mask}"].each {|file| require File.join Dir.pwd, file }
end