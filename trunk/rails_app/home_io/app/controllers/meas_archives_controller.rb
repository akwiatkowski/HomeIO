class MeasArchivesController < ApplicationController
  has_scope :meas_type_id
  has_scope :time_from
  has_scope :time_to


  # GET /meas_archives
  # GET /meas_archives.xml
  def index
    #@meas_archives = apply_scopes(MeasArchive).order("time_from DESC").paginate(:page => params[:page], :per_page => 20 * mobile_pagination_multiplier)
    meas_archives = apply_scopes(MeasArchive).order("time_from DESC")

    respond_to do |format|
      format.html { @meas_archives = meas_archives.paginate(:page => params[:page], :per_page => 20 * mobile_pagination_multiplier) } # index.html.erb
      format.xml {
        @meas_archives = meas_archives.limit(1000).all
        render :xml => @meas_archives.to_xml
      }
      format.json {
        @meas_archives = meas_archives.limit(1000).all
        render :json => @meas_archives
      }
      format.json_graph {
        @meas_archives = meas_archives.paginate(:page => params[:page], :per_page => 20 * mobile_pagination_multiplier)
        render :json => MeasArchive.to_json_graph(@meas_archives)
      }
      format.png {
        @meas_archives = meas_archives.limit(1000)
        string = UniversalGraph.process_meas(@meas_archives, params[:format], params[:antialias])
        send_data(string, :type => 'image/png', :disposition => 'inline')
      }
      format.svg {
        @meas_archives = meas_archives.limit(1000)
        string = UniversalGraph.process_meas(@meas_archives, params[:format], params[:antialias])
        render :text => string
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
      f.series(:name => @meas_type.name_human, :data => @meas_archives.collect { |m| [m.time_to.to_f, m.value] })
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
