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

  # What is returned when user was not polite
  EMPTY = {
    :meas => []
  }

  # Standard project wide options for graph
  GRAPH_STD_OPTIONS = UniversalGraph::STD_OPTIONS

  ADMIN_USER_LIMIT = 500_000
  REGULAR_USER_LIMIT = 20_000

  # Load measurements, create graph when needed
  def self.find(params, user)
    return EMPTY if params[:time_from].blank? or params[:time_to].blank? or params[:meas_type_group_id].blank?
    time_from = params[:time_from].to_time
    time_to = params[:time_to].to_time
    meas_type_group_id = params[:meas_type_group_id].to_i
    antialias = params[:antialias] == 'true'
    format = params[:format]

    # output, and place to store all useful variables
    hash_output = Hash.new
    meas = Array.new

    group = MeasTypeGroup.find(meas_type_group_id)
    group.meas_types.each do |mt|
      puts "Fetching type #{mt.name}"

      mh = {
        :meas_type => mt,
        :meas_archives => MeasArchive.where(
          ["meas_type_id = ? and time_from between ? and ?", mt.id, time_from, time_to]
        ).limit(meas_archive_limit(user)).all
      }
      meas << mh
    end
    puts "Fetching phase complete"

    if format == 'png' or format == 'svg'
      # create graph
      h = GRAPH_STD_OPTIONS.clone.merge(
        {
          :x_axis_label => 'hours',
          :y_axis_label => 'value',

          :x_axis_interval => 3600,
          :y_axis_count => group.y_interval,
          :x_axis_fixed_interval => true,
          :y_axis_fixed_interval => false,
          #:width => WIDTH,
          #:height => HEIGHT,

          :y_min => group.y_min,
          :y_max => group.y_max,

          :layers_antialias => antialias,
          :font_antialias => antialias,
          :layers_antialias => antialias,

          :legend => true,
          :legend_auto => true,
          :legend_width => 140,
          :legend_margin => 60,

          :axis_density_enlarge_image => true,
          :x_axis_min_distance => 60,
          :y_axis_min_distance => 40,
        }
      )

      # process measurements and adding layers
      tg = TechnicalGraph.new(h)

      meas.each do |m|
        data = Array.new
        m[:meas_archives].each do |w|
          data << { :x => (w.time_from - Time.now)/3600, :y => w.value }
          # current measurements has identical times
          if not w.time_from == w.time_to
            data << { :x => (w.time_to - Time.now)/3600, :y => w.value }
          end
        end

        layer_params = {
          :antialias => antialias,
          :label => m[:meas_type].name_human
        }

        puts "Adding layer #{m[:meas_type].name_human}"
        tg.add_layer(data, layer_params)
        puts "Layer added"
      end

      puts "Graph rendered"
      tg.render

      if format == 'png'
        hash_output[:graph] = tg.image_drawer.to_png
      end

      if format == 'svg'
        # not implemented in library yet
        #hash_output[:graph] = tg.image_drawer.to_svg
      end
    end

    # limited output
    hash_output[:meas] = Array.new
    meas.each do |m|
      hash_output[:meas] << {
        :meas_type => m[:meas_type],
        :time_from => time_from,
        :time_to => time_from,
        :meas_type_group => group,
        :meas_archives_count => m[:meas_archives].size
      }
    end

    return hash_output
  end

  # Admin users can start processing bigger requests
  def self.meas_archive_limit(user)
    return ADMIN_USER_LIMIT if user.admin?
    return REGULAR_USER_LIMIT
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


    tg.add_layer(data)
    tg.render

    return tg.image_drawer.to_png
  end

end