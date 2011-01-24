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


# Some new methods

class String

  # Odkodowanie co oznacza dany kod METAR - jakie miasto
  def encode_metar_name
    c = MetarTools.load_config
    o = c[:cities].select{|city| city[:code] == self}
    if o.size == 1
      return o.first[:name]
    else
      return self
    end
  end
end