class UniversalGraph
  WIDTH = 2000
  HEIGHT = 1500

  # TODO: make it DRY

  def self.process_weather(weather_data, type)
    type = "temperature" if type.nil?

    data = Array.new
    weather_data.each do |w|
      data << { :x => (Time.now - w.time_from) / 3600.0, :y => w.attributes[type] }
      data << { :x => (Time.now - w.time_to) / 3600.0, :y => w.attributes[type] }
    end

    xs = data.collect { |d| d[:x] }
    ys = data.collect { |d| d[:y] }

    h = {
      :x_axis_label => 'hours',
      :y_axis_label => 'value',

      :x_axis_interval => 12.0, # 12 hours
      :y_axis_count => 10,
      :x_axis_fixed_interval => true,
      :y_axis_fixed_interval => false,
      :width => WIDTH,
      :height => HEIGHT,

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
    data = Array.new
    meas_data.each do |w|
      data << { :x => (Time.now - w.time_from) / 60.0, :y => w.value }
      data << { :x => (Time.now - w.time_to) / 60.0, :y => w.value }
    end

    xs = data.collect { |d| d[:x] }
    ys = data.collect { |d| d[:y] }

    h = {
      :x_axis_label => 'minutes',
      :y_axis_label => 'value',

      :x_axis_interval => 60.0,
      :y_axis_count => 10,
      :x_axis_fixed_interval => true,
      :y_axis_fixed_interval => false,
      :width => WIDTH,
      :height => HEIGHT,

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