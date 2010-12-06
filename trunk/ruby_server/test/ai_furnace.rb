require './lib/plugins/ai_furnace'
require 'test/unit'

class TestConfigLoader < Test::Unit::TestCase

  def test_basic
    a = AiFurnace.new

    weather_data = []
    furnace_data = []

    50_000.times do
      weather_data << [ rand(30) - 20, rand(5) ]
    end

    (0...(weather_data.size)).each do |i|
      #      if weather_data[i][0] > 10.0
      #        #furnace_data << [0, 0]
      #        furnace_data << [0.1]
      #      elsif weather_data[i][0] > 5.0
      #        #furnace_data << [0.1, 0.3]
      #        furnace_data << [0.2]
      #      elsif weather_data[i][0] > 0.0
      #        #furnace_data << [0.2, 0.4]
      #        furnace_data << [0.4]
      #      elsif weather_data[i][0] > -5.0
      #        #furnace_data << [0.4, 0.4]
      #        furnace_data << [0.5]
      #      else
      #        #furnace_data << [0.5, 0.4]
      #        furnace_data << [0.7]
      #      end

      furnace_data << [ (-1 * weather_data[i][0] + 20) / 40 + 0.02 * weather_data[i][1] ]
    end

    a.teach(weather_data, furnace_data)

    puts a.eval([1, 5]).inspect
    puts a.eval([8, 0]).inspect
    puts a.eval([-14, 8]).inspect
  end

end

