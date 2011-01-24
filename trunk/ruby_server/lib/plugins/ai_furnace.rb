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


require 'rubygems'
require 'ai4r'
require 'ruby_fann/neural_network'
require './lib/utils/config_loader.rb'
require './lib/utils/core_classes.rb'

# TODO
# http://pallas.telperion.info/ruby-stats/

class AiFurnace

  attr_reader :net_a, :net_b, :furnace_input

  # coefficient when measuring slag
  SLAG_COEF = 9.0
  # previous day redistribution coefficient
  # when furnace burn material without removing slag for more than 1 day
  PREV_DAY_COEF = 0.4

  def initialize
    # Create the network with:
    #   4 inputs
    #   1 hidden layer with 3 neurons
    #   2 outputs
    
    #@net = Ai4r::NeuralNetwork::Backpropagation.new([4, 2])
    #@net = Ai4r::NeuralNetwork::Backpropagation.new([4, 3, 2, 1])

    @net_a = RubyFann::Standard.new(
      :num_inputs => 2,
      :hidden_neurons => [3],
      :num_outputs => 1
    )

    @net_b = Ai4r::NeuralNetwork::Backpropagation.new([4, 3, 1])
  end

  # Load yaml input file from observations
  def load_input
    loaded_data = ConfigLoader.instance.load_input( self.class.to_s )
    loaded_data = loaded_data.sort{|a,b| a[:day] <=> b[:day]}

    (0...(loaded_data.size)).each do |i|
      fd = loaded_data[i]
      fd[:fuel_processed] = fd[:slag].to_f * SLAG_COEF
    end

    @furnace_input = loaded_data
    50.times do
      furnace_data_zero_smoothing
    end
  end

  private

  # Simple processing - smoothe data for days when where was no
  # removing of slag from furnace
  def furnace_data_zero_smoothing
    (0...(@furnace_input.size)).each do |i|
      prev_i = i - 1
      fd = @furnace_input[i]
      fd_prev = @furnace_input[prev_i]

      # redistributions to previous days
      if prev_i > 0 and not fd_prev.nil? and fd_prev[:fuel_processed] == 0.0
        redistr = fd[:fuel_processed] * PREV_DAY_COEF
        fd[:fuel_processed] -= redistr
        fd_prev[:fuel_processed] += redistr
      end

    end
  end
  public

  def show_furnace_data
    @furnace_input.each do |f|
      puts "#{f[:day].to_human} - #{f[:slag]} - #{f[:fuel_processed]}"
    end
  end

  # Teach network using logged data
  def teach( weather_data, furnace_data )
    raise 'Wrong data sizes' if weather_data.size != furnace_data.size

    training_data = RubyFann::TrainData.new(
      :inputs => weather_data,
      :desired_outputs => furnace_data)

    #
    #    (0...(weather_data.size)).each do |i|
    #      # Train the network
    #      error = @net.train( weather_data[i], furnace_data[i] )
    #      puts weather_data[i].inspect + " " + furnace_data[i].inspect if error > 1.0
    #    end

    #@net.train_on_data(training_data, 1000, 1, 0.1)
    @net_a.train_on_data(training_data, 1000, 1, 0.1)

    @net_b.train(weather_data, furnace_data)
  end

  def eval( weather_data )
    # Use it: Evaluate data with the trained network
    #puts weather_data.inspect
    #return @net.eval( weather_data )

    #return @net.run( weather_data )

    return {
      :a => @net_a.run( weather_data ),
      :b => @net_b.eval( weather_data )
    }
  end

end
