class WeatherMetarArchivesController < ApplicationController
  has_scope :city_id

  # GET /weather_metar_archives
  # GET /weather_metar_archives.xml
  def index
    authorize! :read, WeatherMetarArchive
    @weather_metar_archives = apply_scopes(WeatherMetarArchive).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weather_metar_archives }
    end
  end

  # GET /weather_metar_archives/1
  # GET /weather_metar_archives/1.xml
  def show
    authorize! :read, WeatherMetarArchive
    @weather_metar_archive = WeatherMetarArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weather_metar_archive }
    end
  end

end
