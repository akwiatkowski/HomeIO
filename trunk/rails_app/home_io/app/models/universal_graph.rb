class UniversalGraph
  WIDTH = 3000
  HEIGHT = 2000

  STD_OPTIONS = {
    :axis_antialias => false,

    :layers_font_size => 10,
    :axis_font_size => 10,
    :axis_label_font_size => 24
  }

  # TODO: make it DRY

  def self.process_weather(weather_data, type, antialias = false)
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
      :y_max => ys.max,

      :layers_antialias => antialias,
      :font_antialias => antialias
    }.merge(STD_OPTIONS)

    tg = TechnicalGraph.new(h)
    tg.add_layer(data)
    tg.render

    return tg.image_drawer.to_png
  end

  def self.process_meas(meas_data, format = :svg, antialias = false)
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

      :antialias => antialias
    }.merge(STD_OPTIONS)

    layer_params = {
      :simple_smoother => true,
      :simple_smoother_level => 20,
      :simple_smoother_strategy => :gauss,
      :simple_smoother_x => true,
      :color => 'red'
    }
    layer_params_raw = {
      :color => 'blue'
    }

    tg = TechnicalGraph.new(h)
    tg.add_layer(data, layer_params_raw)
    tg.add_layer(data, layer_params)
    tg.render

    return tg.image_drawer.to_format(format)
  end

end