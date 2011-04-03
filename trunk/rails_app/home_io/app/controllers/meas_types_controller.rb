class MeasTypesController < ApplicationController
  # GET /meas_types
  # GET /meas_types.xml
  def index
    @meas_types = MeasType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meas_types }
    end
  end

  # GET /meas_types/current
  # GET /meas_types/current.xml
  def current
    @meas_types = MeasType.all
    @meas_archives = Array.new
    @meas_types.each do |mt|
      @meas_archives << mt.meas_archives.last
    end
    @meas_archives = @meas_archives.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @meas_archives }
    end
  end

  # GET /meas_types/1
  # GET /meas_types/1.xml
  def show
    @meas_type = MeasType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_type }
    end
  end

  # GET /meas_types/new
  # GET /meas_types/new.xml
  def new
    @meas_type = MeasType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meas_type }
    end
  end

  # GET /meas_types/1/edit
  def edit
    @meas_type = MeasType.find(params[:id])
  end

  # POST /meas_types
  # POST /meas_types.xml
  def create
    @meas_type = MeasType.new(params[:meas_type])

    respond_to do |format|
      if @meas_type.save
        format.html { redirect_to(@meas_type, :notice => 'Meas type was successfully created.') }
        format.xml  { render :xml => @meas_type, :status => :created, :location => @meas_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meas_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meas_types/1
  # PUT /meas_types/1.xml
  def update
    @meas_type = MeasType.find(params[:id])

    respond_to do |format|
      if @meas_type.update_attributes(params[:meas_type])
        format.html { redirect_to(@meas_type, :notice => 'Meas type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meas_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meas_types/1
  # DELETE /meas_types/1.xml
  def destroy
    @meas_type = MeasType.find(params[:id])
    @meas_type.destroy

    respond_to do |format|
      format.html { redirect_to(meas_types_url) }
      format.xml  { head :ok }
    end
  end
end
