class WeatherArchivesController < ApplicationController
  has_scope :city_id

  # GET /weather_archives
  # GET /weather_archives.xml
  def index
    authorize! :read, WeatherArchive
    #@weather_archives = WeatherArchive.paginate( :page => params[:page], :conditions => {:city_id => params[:city_id]} )
    @weather_archives = apply_scopes(WeatherArchive).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weather_archives }
    end
  end

  # GET /weather_archives/1
  # GET /weather_archives/1.xml
  def show
    authorize! :read, WeatherArchive
    @weather_archive = WeatherArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weather_archive }
    end
  end

end
