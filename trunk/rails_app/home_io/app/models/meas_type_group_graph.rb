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


# Measurements groups, graph creation

class MeasTypeGroupGraph

  def self.find(params)
    group = MeasTypeGroup.find(params[:meas_type_group_id])

    return group
  end
  
  def self.process_meas_group(meas_data, antialias = false)
    data = Array.new

    t = meas_data.sort { |a, b| a.time_from <=> b.time_from }
    if (t.last.time_from - t.first.time_from) > 120.0
      minutes = true
    end

    if minutes
      x_label = "minutes, time"
      divider = 60.0
      x_interval = 1.0
    else
      x_label = "10 seconds, time"
      divider = 1.0
      x_interval = 10.0
    end

    meas_data.each do |w|
      data << { :x => (Time.now - w.time_from) / divider, :y => w.value }
      # current measurements has identical times
      if not w.time_from == w.time_to
        data << { :x => (Time.now - w.time_to) / divider, :y => w.value }
      end
    end

    xs = data.collect { |d| d[:x] }
    ys = data.collect { |d| d[:y] }

    h = {
      :x_axis_label => x_label,
      :y_axis_label => 'value',

      :x_axis_interval => x_interval,
      :y_axis_count => 10,
      :x_axis_fixed_interval => true,
      :y_axis_fixed_interval => false,
      :width => WIDTH,
      :height => HEIGHT,

      :x_min => xs.min,
      :x_max => xs.max,
      :y_min => ys.min,
      :y_max => ys.max,

      :layers_antialias => antialias,
      :font_antialias => antialias
    }.merge(STD_OPTIONS)

    tg = TechnicalGraph.new(h)
    tg.add_layer(data)
    tg.render

    return tg.image_drawer.to_png
  end

end