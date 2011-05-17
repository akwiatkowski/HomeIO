class MeasTypesController < ApplicationController
  # GET /meas_types
  # GET /meas_types.xml
  def index
    @meas_types = MeasType.all
    authorize! :read, MeasType

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @meas_types }
    end
  end

  # GET /meas_types/current
  # GET /meas_types/current.xml
  def current
    authorize! :read, MeasArchive
    begin
      # using direct connection to background
      @meas_archives = BackendProtocol.current_meas
    rescue Errno::ECONNREFUSED => e
      # no active connection to backend
      @meas_archives = MeasArchive.all_types_last_measurements
      no_direct_connection_to_backend
    end

    @meas_archives = @meas_archives.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.xml { render :xml => @meas_archives }
      #format.json { render :json => @meas_archives }
      format.json { render :json => @meas_archives.to_json(:include => :meas_type) }
    end
  end

  def auto_refresh
  end

  # GET /meas_types/1
  # GET /meas_types/1.xml
  def show
    @meas_type = MeasType.find(params[:id])
    authorize! :read, MeasType

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @meas_type }
    end
  end

  # GET /meas_types/new
  # GET /meas_types/new.xml
  def new
    @meas_type = MeasType.new
    authorize! :read, MeasType

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @meas_type }
    end
  end

  # GET /meas_types/1/edit
  def edit
    @meas_type = MeasType.find(params[:id])
    authorize! :read, MeasType
  end

  # POST /meas_types
  # POST /meas_types.xml
  def create
    return # TODO fix it later

    @meas_type = MeasType.new(params[:meas_type])
    authorize! :manage, MeasType

    respond_to do |format|
      if @meas_type.save
        format.html { redirect_to(@meas_type, :notice => 'Meas type was successfully created.') }
        format.xml { render :xml => @meas_type, :status => :created, :location => @meas_type }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @meas_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meas_types/1
  # PUT /meas_types/1.xml
  def update
    return # TODO fix it later

    @meas_type = MeasType.find(params[:id])
    authorize! :manage, MeasType

    respond_to do |format|
      if @meas_type.update_attributes(params[:meas_type])
        format.html { redirect_to(@meas_type, :notice => 'Meas type was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @meas_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meas_types/1
  # DELETE /meas_types/1.xml
  def destroy
    return # TODO fix it later

    @meas_type = MeasType.find(params[:id])
    authorize! :manage, MeasType
    @meas_type.destroy

    respond_to do |format|
      format.html { redirect_to(meas_types_url) }
      format.xml { head :ok }
    end
  end
end
