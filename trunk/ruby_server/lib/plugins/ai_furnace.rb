require 'rubygems'
require 'ai4r'
require 'ruby_fann/neural_network'


# To change this template, choose Tools | Templates
# and open the template in the editor.

class AiFurnace

  attr_reader :net

  def initialize
    # Create the network with:
    #   4 inputs
    #   1 hidden layer with 3 neurons
    #   2 outputs
    
    #@net = Ai4r::NeuralNetwork::Backpropagation.new([4, 2])
    #@net = Ai4r::NeuralNetwork::Backpropagation.new([4, 3, 2, 1])

    @net = RubyFann::Standard.new(
      :num_inputs => 2,
      :hidden_neurons => [3],
      :num_outputs => 1)
  end

  # Teach network using logged data
  def teach( weather_data, furnace_data )
    raise 'Wrong data sizes' if weather_data.size != furnace_data.size

    training_data = RubyFann::TrainData.new(
      :inputs=> weather_data,
      :desired_outputs=> furnace_data)

    #
    #    (0...(weather_data.size)).each do |i|
    #      # Train the network
    #      error = @net.train( weather_data[i], furnace_data[i] )
    #      puts weather_data[i].inspect + " " + furnace_data[i].inspect if error > 1.0
    #    end

    #@net.train_on_data(training_data, 1000, 1, 0.1)
    @net.train_on_data(training_data, 1000, 1, 0.1)

  end

  def eval( weather_data )
    # Use it: Evaluate data with the trained network
    #puts weather_data.inspect
    #return @net.eval( weather_data )

    return @net.run( weather_data )
  end

end
