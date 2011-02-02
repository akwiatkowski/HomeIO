class WeatherMetarArchivesController < ApplicationController
  # GET /weather_metar_archives
  # GET /weather_metar_archives.xml
  def index
    @weather_metar_archives = WeatherMetarArchive.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weather_metar_archives }
    end
  end

  # GET /weather_metar_archives/1
  # GET /weather_metar_archives/1.xml
  def show
    @weather_metar_archive = WeatherMetarArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weather_metar_archive }
    end
  end

  # GET /weather_metar_archives/new
  # GET /weather_metar_archives/new.xml
  def new
    @weather_metar_archive = WeatherMetarArchive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @weather_metar_archive }
    end
  end

  # GET /weather_metar_archives/1/edit
  def edit
    @weather_metar_archive = WeatherMetarArchive.find(params[:id])
  end

  # POST /weather_metar_archives
  # POST /weather_metar_archives.xml
  def create
    @weather_metar_archive = WeatherMetarArchive.new(params[:weather_metar_archive])

    respond_to do |format|
      if @weather_metar_archive.save
        format.html { redirect_to(@weather_metar_archive, :notice => 'Weather metar archive was successfully created.') }
        format.xml  { render :xml => @weather_metar_archive, :status => :created, :location => @weather_metar_archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @weather_metar_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weather_metar_archives/1
  # PUT /weather_metar_archives/1.xml
  def update
    @weather_metar_archive = WeatherMetarArchive.find(params[:id])

    respond_to do |format|
      if @weather_metar_archive.update_attributes(params[:weather_metar_archive])
        format.html { redirect_to(@weather_metar_archive, :notice => 'Weather metar archive was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weather_metar_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weather_metar_archives/1
  # DELETE /weather_metar_archives/1.xml
  def destroy
    @weather_metar_archive = WeatherMetarArchive.find(params[:id])
    @weather_metar_archive.destroy

    respond_to do |format|
      format.html { redirect_to(weather_metar_archives_url) }
      format.xml  { head :ok }
    end
  end
end
