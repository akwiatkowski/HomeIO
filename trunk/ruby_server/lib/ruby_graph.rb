require 'rubygems'
require 'RMagick'
require 'date'

# Klasa do budowy klas tworzących wykresy
#
# @draw_options - konfiguracja domyślna wszystkich wykresów
# @graph_directives - konfiguracja domyślna danego wykresu
# @width, @height - wymiary wykresu
#
# @data_for_graph - dane do wykresu w wartościach rzeczywistych {:x => unix_time,
#  :y => wartość}
# @graph_points - punkty wykresu, współrzędne bitmapy
#
# @x_axis_interval_seconds - oś pionowa na wykresie co sekund
# @x_axis_interval_pixels - oś pionowa na wykresie co tyle pikseli
#
# @options - hasz opcji odebranych z polecenia, gdy nie ma używane są wartości
# domyślne lub z ustawień wykresu
# * :x_min, :x_max, :y_min, :y_max - zmiana zakresów wykresu
# * :desc - opis wykresu
# * :x_axis_every_seconds - co ile sekund wykres
#
# TODO: kilka wykresów na jednym

class RubyGraph

  # domyślna wielkość wykresu
  WIDTH = 1600
  HEIGHT = 1200
  # czy wyświetlać komunikaty
  VERBOSE = true
  # domyślnie oś X co dobę
  AXIS_X_EVERY = 24*3600


  # Domyślne wartości
  def initialize
    @width = WIDTH
    @height = HEIGHT
    @x_axis_interval_seconds= AXIS_X_EVERY
  end


  # Przetwarzanie danych
  def prepare_data_for_graph

    # rozmiary wykresu

    @width = @draw_options[:width] if not @draw_options[:width].nil?
    @height = @draw_options[:height] if not @draw_options[:height].nil?

    # usunięcie błędnych danych
    @data_for_graph.delete_if{ |d| d[:x].nil? or d[:y].nil?  }

    # posortowanie po czasie
    @data_for_graph.sort!{ |d,e| d[:x] <=> e[:x]}

    # zakresy X (czas unixowy)
    @x_min = @data_for_graph.first[:x]
    @x_max = @data_for_graph.last[:x]

    @x_min = @options[:xy_min] if not @options[:x_min].nil?
    @x_max = @options[:x_max] if not @options[:x_max].nil?


    # zakresy Y
    y_sort = @data_for_graph.sort{ |d,e| d[:y] <=> e[:y]}
    @y_min = y_sort.first[:y]
    @y_max = y_sort.last[:y]

    @y_min = @graph_directives[:y_min] if not @graph_directives[:y_min].nil?
    @y_max = @graph_directives[:y_max] if not @graph_directives[:y_max].nil?

    @y_min = @options[:y_min] if not @options[:y_min].nil?
    @y_max = @options[:y_max] if not @options[:y_max].nil?



    # etykieta wykresu
    @desc = "WYKRES"
    @desc = @graph_directives[:desc] if not @graph_directives[:desc].nil?
    @desc = @options[:desc] if not @options[:desc].nil?

    # ustawienie obszarów czasowych
    calculate_time_ranges

    # przetworzone - przeskalowane do wykresu
    @graph_points = Array.new

    
    # skale i przesunięcia do konwersji
    @scale_x = @width.to_f / (@x_max.to_f - @x_min.to_f)
    @scale_y = @height.to_f / (@y_max.to_f - @y_min.to_f)
    @offset_x = -1.0 * @x_min.to_f
    @offset_y = @y_max

    # konwersja współrzędnych
    @data_for_graph.each do |g|
      @graph_points << {
        :x => conv_x( g[:x] ),
        :y => conv_y( g[:y] ),
      }
    end

    # osie pionowe co ile sekund
    @x_axis_interval_seconds = @options[:x_axis_every_seconds] if not @options[:x_axis_every_seconds].nil?

    if VERBOSE == true
      puts "RANGES X #{@x_min} - #{@x_max}, Y #{@y_min} - #{@y_max}"
      puts "scale_x #{@scale_x}, offset_x #{@offset_x}"
      puts "scale_y #{@scale_y}, offset_y #{@offset_y}"
    end

  end

  # Ustawianie zakresów czasowych w zależności od polecenia
  def calculate_time_ranges
    # wykresy pełnomiesięczne

    case @options[:time_range]
    when :one_month
      # wykresy jednego miesiąca
      @x_min = Time.at( @x_min ).utc_begin_of_month.to_i
      @x_max = Time.at( @x_min ).utc_end_of_month.to_i

    else
      # domyślnie pełne miesiace, z szacunkiem 5 dni
      @x_min = Time.at( @x_min ).utc_begin_of_month.to_i

      # sprawdzenie aby dla kilku dni nie dodawał kolejnego miesiąca
      x_max_finish = Time.at( @x_max ).utc_end_of_month.to_i
      #x_max_begin = Time.at( @x_max ).utc_begin_of_month.to_i
      if (x_max_finish - @x_max) > 5 * 36 * 2400
        @x_max = x_max_finish
      end

    end

  end

  private

  def create_simple
    
    # nowy wykres
    @image = new_graph
    
    # osie pionowe
    x_axises

    # osie poziome
    y_axises

    # etykiety czasowe
    time_desc

    # etykieta miasta i wykresu
    graph_desc

    # rysowanie wykresu
    draw_graph_data( @graph_points )
    #draw_graph_data_bezier( @graph_points )

    # zapisywanie wykresu
    save_graph
  end

  # Tworzy nowy wykres, czystą bitmap
  def new_graph
    @image = Magick::ImageList.new
    @image.new_image(
      @width,
      @height,
      Magick::HatchFill.new(
        @draw_options[:background_white],
        @draw_options[:background_nonwhite]
      )
    )

    return @image
  end

  # Osie pionowe
  def x_axises

    # szerokość czasowa w pikselach
    @x_axis_interval_pixels = conv_x( @x_min + @x_axis_interval_seconds)

    plot_axis_x = Magick::Draw.new
    plot_axis_x.fill_opacity(0)
    plot_axis_x.stroke( @draw_options[:normal_axis_color] )
    plot_axis_x.stroke_opacity( 1.0 )
    plot_axis_x.stroke_width( 1.0 )
    plot_axis_x.stroke_linecap('square')
    plot_axis_x.stroke_linejoin('miter')

    axis_x = @x_axis_interval_pixels

    # pętla co interwał
    while axis_x < @width
      # oś
      plot_axis_x.line( axis_x.round,0, axis_x.round,@image.rows-1 )
      axis_x += @x_axis_interval_pixels
    end

    plot_axis_x.draw(@image)


    # etykiety osi
    x_axises_caption
  end


  # Osie poziome
  def y_axises

    # od jakiego rozpocznie w pikselach
    y_axis_start = conv_y( @y_min )
    y_axis_value = @y_min #aktualna wartość przy osi
    y_axis_interval = conv_y( @y_min + @graph_directives[:y_axis] ) - y_axis_start

    plot_axis_y_line = Magick::Draw.new
    plot_axis_y_text = Magick::Draw.new

    plot_axis_y_line.fill_opacity(0)
    plot_axis_y_line.stroke( @draw_options[:normal_axis_color] )
    plot_axis_y_line.stroke_opacity( 1.0 )
    plot_axis_y_line.stroke_width( 1.0 )
    plot_axis_y_line.stroke_linecap('square')
    plot_axis_y_line.stroke_linejoin('miter')

    plot_axis_y_text.font_family( 'helvetica' )
    plot_axis_y_text.font_style( Magick::NormalStyle )
    plot_axis_y_text.text_align( Magick::LeftAlign )
    plot_axis_y_text.text_undercolor( @draw_options[:background_white] )


    axis_y = y_axis_start

    # pętla co zdefiniowany interwał
    while axis_y >= 0
      # oś
      plot_axis_y_line.line(
        0, axis_y.round,
        @image.columns-1, axis_y.round
      )

      # etykieta danych
      plot_axis_y_text.text(
        5,
        axis_y.round + 15,
        "'#{y_axis_value} #{@graph_directives[:unit_name].to_s}'"
      )


      axis_y += y_axis_interval
      y_axis_value += @graph_directives[:y_axis]
    end

    plot_axis_y_line.draw(@image)
    plot_axis_y_text.draw(@image)
  end

  # Etykieta czasowa początku oraz końca przedziału
  def time_desc
    td = Magick::Draw.new

    # TODO możliwośc zmiany tego w opcjach wykresu
    time_format_string = "%Y-%m-%d %H:%M:%S"

    td.fill_opacity( 1.0)
    td.stroke_width( 0.0 )
    td.font_family( 'helvetica' )
    td.font_style( Magick::NormalStyle )
    td.font_weight( 100 )
    
    td.text_undercolor( @draw_options[:background_white] )

    td.text_align(Magick::LeftAlign)
    td.text(
      5,
      15,
      "'#{Time.at(@x_min).utc.strftime( time_format_string )}'"
    )

    td.text_align(Magick::RightAlign)
    td.text(
      @image.columns - 6,
      15,
      "'#{Time.at(@x_max).utc.strftime( time_format_string )}'"
    )

    td.draw(@image)
  end

  # Etykieta miasta i typu wykresu
  def graph_desc
  end

  # Rysuje wykres dla podanych danych w tabeli {:x, :y}, gdzie dane już są 
  # w pikselach
  def draw_graph_data( data )
    
    # kolor wykresu, domyślny lub określony dla typu
    plot_color = @draw_options[:plot_color]
    plot_color = @graph_directives[:plot_color] if not @graph_directives[:plot_color].nil?
    
    plot = Magick::Draw.new
    plot.stroke( plot_color )
    plot.fill_opacity(0)
    plot.stroke_opacity( @graph_directives[:plot_opacity] || @draw_options[:plot_opacity] )
    plot.stroke_width( @draw_options[:plot_width] )
    plot.stroke_linecap( 'round' )
    plot.stroke_linejoin( 'round' )

    prev_data = nil

    # pętla po danych
    data.each do |pg|
      
      # jeżeli nie było zbyt dużej przerwy będzie rysowana linia
      if not prev_data.nil? and (pg[:x] - prev_data[:x]) < 2*3600
        plot.polyline(
          prev_data[:x].round,  prev_data[:y].round,
          pg[:x].round,  pg[:y].round
        )
      end

      plot.circle(
        pg[:x],
        pg[:y],
        pg[:x] + 1,
        pg[:y] + 1
      )

      prev_data = pg
    end

    plot.draw(@image)
  end


    # Rysuje wykres dla podanych danych w tabeli {:x, :y}, gdzie dane już są
  # w pikselach
  def draw_graph_data_bezier( data )

    # kolor wykresu, domyślny lub określony dla typu
    plot_color = @draw_options[:plot_color]
    plot_color = @graph_directives[:plot_color] if not @graph_directives[:plot_color].nil?

    plot = Magick::Draw.new
    plot.stroke( plot_color )
    plot.fill_opacity(0)
    plot.stroke_opacity( @graph_directives[:plot_opacity] || @draw_options[:plot_opacity] )
    plot.stroke_width( @draw_options[:plot_width] )
    plot.stroke_linecap( 'round' )
    plot.stroke_linejoin( 'round' )

    # pętla po danych
    (0...data.size).each do |i|

      plot.circle(
        data[i][:x],
        data[i][:y],
        data[i][:x] + 1,
        data[i][:y] + 1
      )

      if not i < 3 and not (data.size - i) < 3
        # beziery
        plot.bezier(
          data[i-2][:x],  data[i-2][:y],
          data[i-1][:x],  data[i-1][:y],
          data[i][:x],    data[i][:y],
          data[i+1][:x],  data[i+1][:y]
        )
      else
        # zwykłe linie
        plot.line(
          data[i-1][:x],  data[i-1][:y],
          data[i][:x],    data[i][:y]
        )
      end

    end

    plot.draw(@image)
  end

  # Saves graph file
  def save_graph
    @image.write( MetarTools.output_graph_filename( @city, @year, @month, @which) )
  end

  private

  # Zamienia współrzędną czasową X na współrzędną na wykresie X
  def conv_x( x )
    return (x + @offset_x) * @scale_x
  end

  # Zamienia współrzędną wartości Y na współrzędną na wykresie Y
  def conv_y( y )
    return (@offset_y - y) * @scale_y
  end


  # Z pliku konfiguracyjnego pobiera konfigurację wykresu
  def load_directives
    config = MetarTools.load_config
    @graph_directives = config[:data_process_directives][@which]
    @draw_options = config[:graph_draw_options]
  end






  # Etykieta osi X - pusta przykładowa funkcja
  def x_axises_caption( every_axises = 5 )
  end







  def sample

    # Demonstrate the use of RMagick's Draw class
    # and show the default coordinate system.

    # Create a @image to draw on. Use the HatchFill class to
    # cross-hatch the background with light gray lines every 10 pixels.
    @image = Magick::ImageList.new
    @image.new_image(250, 250, Magick::HatchFill.new('white', 'gray90'))

    # Draw a border around the edges of the @image.
    border = Magick::Draw.new
    border.stroke('thistle')
    border.fill_opacity(0)
    border.rectangle(0,0, @image.columns-1, @image.rows-1)
    border.draw(@image)

    # Draw gold axes with arrow-heads.
    axes = Magick::Draw.new
    axes.fill_opacity(0)
    axes.stroke('gold3')
    axes.stroke_width(4)
    axes.stroke_linecap('round')
    axes.stroke_linejoin('round')
    axes.polyline(18,@image.rows-10, 10,@image.rows-3, 3,@image.rows-10,
      10,@image.rows-10, 10,10, @image.columns-10,10,
      @image.columns-10,3, @image.columns-3,10, @image.columns-10, 18)
    axes.draw(@image)

    # Draw a red circle to show the direction of rotation.
    # Make it slightly transparent so the hatching will show through.
    circle = Magick::Draw.new
    circle.stroke('tomato')
    circle.fill_opacity(0)
    circle.stroke_opacity(0.75)
    circle.stroke_width(6)
    circle.stroke_linecap('round')
    circle.stroke_linejoin('round')
    circle.ellipse(@image.rows/2,@image.columns/2, 80, 80, 0, 315)
    circle.polyline(180,70, 173,78, 190,78, 191,62)
    circle.draw(@image)

    # Label the axes and the circle.
    labels = Magick::Draw.new
    labels.font_weight(Magick::NormalWeight)
    labels.fill('black')
    labels.stroke('transparent')
    labels.font_style(Magick::ItalicStyle)
    labels.pointsize(14)
    labels.gravity(Magick::NorthWestGravity)
    labels.text(20,30, "'0,0'")
    labels.gravity(Magick::NorthEastGravity)
    labels.text(20,30, "'+x'")
    labels.gravity(Magick::SouthWestGravity)
    labels.text(20,20, "'+y'")
    labels.gravity(Magick::CenterGravity)
    labels.text(0,0, "Rotation")
    labels.draw(@image)

    #@image.display
    @image.write("axes.png")
    puts "1"


  end
end
