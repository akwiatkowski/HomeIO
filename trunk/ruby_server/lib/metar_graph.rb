require 'lib/ruby_graph'

# Rysowanie wykresów METAR
#
# @yaml_data - dane po wczytaniu pliku YAML, tabela Hashy

class MetarGraph < RubyGraph
  WIDTH = 1600
  HEIGHT = 1200

  def initialize
  end

  # Tworzy wykres dla danych METAR
  def create_graph( proc_data, command )
    # przetworzone dane z pliku YAML
    @yaml_data = proc_data

    # dane ogólne
    @city = command[:city]
    @year = command[:year]
    @month = command[:month]
    @which = command[:which]
    
    # opcje przesyłane w poleceniu
    @options = command[:options]
    @options = Hash.new if @options.nil?

    # osie pionowe - dobowe
    @x_axis_interval_seconds = 24 * 3600

    puts "CREATING GRAPH #{@city}, #{@year}, #{@month}" if VERBOSE == true
    start_graph
    puts "GRAPH FINISHED" if VERBOSE == true

    return :ok

  end

  private

  # Wykonanie wykresu
  def start_graph
    # pobierz dyrektywy do danego wykresu z pliku konfiguracyjnego
    load_directives

    # przygotowuje dane
    metar_prepare_data

    # tworzy wykres
    create_simple

  end

  # Przygotowanie danych dla METAR
  def metar_prepare_data

    # przetworzenie danych do uniwersalnej tabeli
    @data_for_graph = @yaml_data.collect{|d| {:x => d[:time_unix], :y => d[@which]}  }

    # kontynuowanie przetwarzania danych
    prepare_data_for_graph

  end

  # Etykieta osi X
  #
  # +@image+ - obiekt rysunku
  # +every_axises+ - co ile osi dodawaj etykietę
  def x_axises_caption( every_axises = 2 )

    plot_axis_xe = Magick::Draw.new
    plot_axis_xe.fill_opacity(1.0)
    #    plot_axis_xe.stroke( @draw_options[:normal_axis_color] )
    #    plot_axis_xe.stroke_opacity( 1.0 )
    #    plot_axis_xe.stroke_width( 0.0 )
    #    plot_axis_xe.stroke_linecap( 'round' )
    #    plot_axis_xe.stroke_linejoin( 'round' )
    plot_axis_xe.font_family( 'helvetica' )
    plot_axis_xe.font_style( Magick::NormalStyle )
    plot_axis_xe.text_align( Magick::LeftAlign )

    axis_x = @x_axis_interval_pixels
    axis_x_count = 1

    # @x_axis_interval_seconds - co ile sekund oś
    # @x_axis_interval_seconds_pixels - co ile pikseli oś

    # pętla co interwał
    while axis_x < @width
      # etykieta

      plot_axis_xe.text(
        axis_x.round + 4,
        @image.rows - 15,
        #"#{Time.at(@x_min + @x_axis_interval_seconds * axis_x_count).strftime("%Y-%m-%d")}"
        "'#{Time.at(@x_min + @x_axis_interval_seconds * axis_x_count).strftime("%d")}'"
      )

      axis_x += @x_axis_interval_pixels * every_axises
      axis_x_count += every_axises
    end

    plot_axis_xe.draw( @image )

  end

  # Etykieta miasta i typu wykresu
  def graph_desc
    td = Magick::Draw.new

    td.fill_opacity( 1.0)
    td.stroke_width( 0.0 )
    td.font_family( 'helvetica' )
    td.font_style( Magick::NormalStyle )
    td.font_weight( 100 )
    td.text_undercolor( @draw_options[:background_white] )

    td.text_align(Magick::CenterAlign)
    td.text(
      (@image.columns / 2).round,
      15,
      "'#{@graph_directives[:desc]} - #{@city.encode_metar_name} (#{@year}-#{@month})'"
    )

    td.draw(@image)
  end

end
