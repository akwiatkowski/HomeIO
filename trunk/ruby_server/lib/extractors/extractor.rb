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


require './lib/extractors/extractor_active_record.rb'

# General purpose extreactor

class Extractor < ExtractorActiveRecord



  # Not safe method for running custom methods
  # Should be someting case like
  def remote_command( command )
    return nil
    # it's safe now...

    puts command.inspect
    method = command[:method]
    args = command[:args]
    return nil if method.nil?

    begin
      return self.send(method, *args)
    rescue => e
      # error - nil, it is safest
      puts "ERROR"
      puts e.inspect
      puts e.backtrace
      
      return nil
    end
  end

end
