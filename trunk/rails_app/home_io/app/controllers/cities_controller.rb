class CitiesController < ApplicationController
  allow_single_access :only=> [:show, :index]
  has_scope :within_range
  has_scope :page

  # GET /cities
  # GET /cities.xml
  def index
    authorize! :read, City
    @cities = apply_scopes(City).paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @cities }
      #format.png { send_file '', :type => 'image/png', :filename => 'city.png', :disposition => :inline }
    end
  end

  # GET /cities/chart
  # DEPRECATED
  def chart
    @weathers = City.get_all_weather
    authorize! :read, City

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @weathers.to_xml }
      format.json { render :json => @weathers }
      format.json_graph {

        @weathers = @weathers.sort { |a, b| a.city.lat <=> b.city.lat }

        #times = @weathers.collect{|w| (w.time_to - Time.now)/3600 }
        lat = @weathers.collect { |w| w.city.lat }
        temperatures = @weathers.collect { |w| w.temperature }
        winds = @weathers.collect { |w| w.wind }

        render :json => {
          :x => lat,
          :y => [temperatures, winds]
        }
      }
    end
  end


  # GET /cities/1
  # GET /cities/1.xml
  def show
    @city = City.find(params[:id])
    @weathers = @city.last_weather(50)

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @weathers }
      format.json { render :json => @weathers }
      format.json_graph {
        type = params[:type]
        type = "temperature" if type.nil?

        # use time between 'time_from' and 'time_to'
        times = @weathers.collect { |w| ((w.time_from - Time.now) + (w.time_from - Time.now)) / (2 * 3600) }
        values = @weathers.collect { |w| w.attributes[type] }

        render :json => {
          :x => times,
          :y => values
        }
      }
      format.png {
        string = UniversalGraph.process_weather(@weathers, params[:type], params[:antialias])
        send_data(string, :type => 'image/png', :disposition => 'inline')
      }
      # TODO cleanup this controllers, maybe inherited resources
      format.svg {
        string = UniversalGraph.process_weather(@weathers, params[:type], params[:antialias])
        send_data(string, :type => 'image/png', :disposition => 'inline')
      }
    end
  end

  # GET /cities/1/edit
  def edit
    @city = City.find(params[:id])
  end

  # PUT /cities/1
  # PUT /cities/1.xml
  def update
    @city = City.find(params[:id])

    respond_to do |format|
      if @city.update_attributes(params[:city])
        format.html { redirect_to(@city, :notice => 'City was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @city.errors, :status => :unprocessable_entity }
      end
    end
  end

end
