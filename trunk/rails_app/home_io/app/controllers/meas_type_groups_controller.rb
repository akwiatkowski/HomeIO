class MeasTypeGroupsController < ApplicationController
  # GET /meas_type_groups
  # GET /meas_type_groups.xml
  def index
    authorize! :read, MeasTypeGroup
    @meas_type_groups = MeasTypeGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meas_type_groups }
    end
  end

  # GET /meas_type_groups/1
  # GET /meas_type_groups/1.xml
  def show
    authorize! :read, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_type_group }
    end
  end

  def latest
    authorize! :read, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.find(params[:id])

    begin
      # using direct connection to background
      @meas_archives = BackendProtocol.current_meas
    rescue Errno::ECONNREFUSED => e
      # no active connection to backend
      @meas_archives = MeasArchive.all_types_last_measurements
      no_direct_connection_to_backend
    end

    # in next version it would be nice to move this outside of controller
    @meas_archives = @meas_archives.select{|m| not m.nil?}
    @meas_archives = @meas_archives.select{|ma| @meas_type_group.meas_types.include?(ma.meas_type)}
    @meas_archives = @meas_archives.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_archives }
      format.json  { render :json => @meas_archives }
      format.txt { render :layout => nil }# index.html.haml
    end
  end

  # GET /meas_type_groups/new
  # GET /meas_type_groups/new.xml
  def new
    authorize! :manage, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meas_type_group }
    end
  end

  # GET /meas_type_groups/1/edit
  def edit
    authorize! :manage, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.find(params[:id])
  end

  # POST /meas_type_groups
  # POST /meas_type_groups.xml
  def create
    authorize! :manage, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.new(params[:meas_type_group])

    respond_to do |format|
      if @meas_type_group.save
        format.html { redirect_to(@meas_type_group, :notice => 'Meas type group was successfully created.') }
        format.xml  { render :xml => @meas_type_group, :status => :created, :location => @meas_type_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meas_type_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meas_type_groups/1
  # PUT /meas_type_groups/1.xml
  def update
    authorize! :manage, MeasTypeGroup
    @meas_type_group = MeasTypeGroup.find(params[:id])

    respond_to do |format|
      if @meas_type_group.update_attributes(params[:meas_type_group])
        format.html { redirect_to(@meas_type_group, :notice => 'Meas type group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meas_type_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meas_type_groups/1
  # DELETE /meas_type_groups/1.xml
  def destroy
    @meas_type_group = MeasTypeGroup.find(params[:id])
    @meas_type_group.destroy

    respond_to do |format|
      format.html { redirect_to(meas_type_groups_url) }
      format.xml  { head :ok }
    end
  end
end
