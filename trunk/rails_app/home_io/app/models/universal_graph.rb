class UniversalGraph

  # TODO: make it DRY

  def self.process_weather(weather_data, type)
    type = "temperature" if type.nil?

    # use time between 'time_from' and 'time_to'
    data = weather_data.collect { |w|
      {
        :x => ((w.time_from - Time.now) + (w.time_from - Time.now)) / (2 * 3600),
        :y => w.attributes[type]
      }
    }

    xs = data.collect{|d| d[:x]}
    ys = data.collect{|d| d[:y]}

    h = {
        :x_axis_interval => 1.0,
        :y_axis_interval => 10.0,
        :x_axis_fixed_interval => true,
        :y_axis_fixed_interval => true,
        :width => 4000,
        :height => 3000,

        :x_min => xs.min,
        :x_max => xs.max,
        :y_min => ys.min,
        :y_max => ys.max
      }

    tg = TechnicalGraph.new(h)
    tg.add_layer(data)
    tg.render

    return tg.image_drawer.to_png
  end

  def self.process_meas(meas_data)
    # use time between 'time_from' and 'time_to'
    data = meas_data.collect { |w|
      {
        :x => ((w.time_from - Time.now) + (w.time_from - Time.now)) / (2.0),
        :y => w.value
      }
    }

    xs = data.collect{|d| d[:x]}
    ys = data.collect{|d| d[:y]}

    h = {
        :x_axis_interval => 60.0,
        :y_axis_interval => 10.0,
        :x_axis_fixed_interval => true,
        :y_axis_fixed_interval => true,
        :width => 2000,
        :height => 1500,

        :x_min => xs.min,
        :x_max => xs.max,
        :y_min => ys.min,
        :y_max => ys.max
      }

    tg = TechnicalGraph.new(h)
    tg.add_layer(data)
    tg.render

    return tg.image_drawer.to_png
  end

end