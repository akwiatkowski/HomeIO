class MeasArchivesController < ApplicationController
  # GET /meas_archives
  # GET /meas_archives.xml
  def index
    @meas_archives = MeasType.find(params[:meas_type_id]).meas_archives.recent.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @meas_archives }
      format.json_graph  {
        times = Array.new
        values = Array.new

        #times = @meas_archives.collect{|w| ( (w.time_from - Time.now) + (w.time_from - Time.now) ) / ( 2 * 60 ) }
        #values = @meas_archives.collect{|w| w.value }

        @meas_archives.sort{|m,n| m.time_from <=> n.time_from}.each do |ma|
          # measurements will be drawn as horizontal line as time range
          times << (ma.time_from - Time.now) / 60
          times << (ma.time_to - Time.now) / 60


          values << ma.value
          values << ma.value
        end

        render :json => {
          :x => times,
          :y => values
        }
      }
    end
  end

  # GET /meas_archives
  def chart
    @meas_type = MeasType.find(params[:meas_type_id])
    @meas_archives = @meas_type.meas_archives.recent.limit(20)

    # http://www.highcharts.com/ref/#series--data
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      #f.series(:name => @meas_type.name_human, :data => @meas_archives.collect{|m| m.value})
      f.series(:name => @meas_type.name_human, :data => @meas_archives.collect{|m| [m.time_to.to_f, m.value]})
      puts f.chart[:legend][:style][:left] = '10px'
    end

  end

  # GET /meas_archives/1
  # GET /meas_archives/1.xml
  def show
    @meas_archive = MeasArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @meas_archive }
    end
  end

  # GET /meas_archives/new
  # GET /meas_archives/new.xml
  def new
    @meas_archive = MeasArchive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @meas_archive }
    end
  end

  # GET /meas_archives/1/edit
  def edit
    @meas_archive = MeasArchive.find(params[:id])
  end

  # POST /meas_archives
  # POST /meas_archives.xml
  def create
    return # TODO fix it later

    @meas_archive = MeasArchive.new(params[:meas_archive])

    respond_to do |format|
      if @meas_archive.save
        format.html { redirect_to(@meas_archive, :notice => 'Meas archive was successfully created.') }
        format.xml { render :xml => @meas_archive, :status => :created, :location => @meas_archive }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @meas_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meas_archives/1
  # PUT /meas_archives/1.xml
  def update
    return # TODO fix it later

    @meas_archive = MeasArchive.find(params[:id])

    respond_to do |format|
      if @meas_archive.update_attributes(params[:meas_archive])
        format.html { redirect_to(@meas_archive, :notice => 'Meas archive was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @meas_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meas_archives/1
  # DELETE /meas_archives/1.xml
  def destroy
    return # TODO fix it later

    @meas_archive = MeasArchive.find(params[:id])
    @meas_archive.destroy

    respond_to do |format|
      format.html { redirect_to(meas_archives_url) }
      format.xml { head :ok }
    end
  end
end
