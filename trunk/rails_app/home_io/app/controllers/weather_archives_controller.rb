class WeatherArchivesController < ApplicationController
  # GET /weather_archives
  # GET /weather_archives.xml
  def index
    @weather_archives = WeatherArchive.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @weather_archives }
    end
  end

  # GET /weather_archives/1
  # GET /weather_archives/1.xml
  def show
    @weather_archive = WeatherArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @weather_archive }
    end
  end

  # GET /weather_archives/new
  # GET /weather_archives/new.xml
  def new
    @weather_archive = WeatherArchive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @weather_archive }
    end
  end

  # GET /weather_archives/1/edit
  def edit
    @weather_archive = WeatherArchive.find(params[:id])
  end

  # POST /weather_archives
  # POST /weather_archives.xml
  def create
    @weather_archive = WeatherArchive.new(params[:weather_archive])

    respond_to do |format|
      if @weather_archive.save
        format.html { redirect_to(@weather_archive, :notice => 'Weather archive was successfully created.') }
        format.xml  { render :xml => @weather_archive, :status => :created, :location => @weather_archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @weather_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /weather_archives/1
  # PUT /weather_archives/1.xml
  def update
    @weather_archive = WeatherArchive.find(params[:id])

    respond_to do |format|
      if @weather_archive.update_attributes(params[:weather_archive])
        format.html { redirect_to(@weather_archive, :notice => 'Weather archive was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @weather_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /weather_archives/1
  # DELETE /weather_archives/1.xml
  def destroy
    @weather_archive = WeatherArchive.find(params[:id])
    @weather_archive.destroy

    respond_to do |format|
      format.html { redirect_to(weather_archives_url) }
      format.xml  { head :ok }
    end
  end
end
