class MeasTypeGroupsController < ApplicationController
  # GET /meas_type_groups
  # GET /meas_type_groups.xml
  def index
    @meas_type_groups = MeasTypeGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meas_type_groups }
    end
  end

  # GET /meas_type_groups/1
  # GET /meas_type_groups/1.xml
  def show
    @meas_type_group = MeasTypeGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_type_group }
    end
  end

  # GET /meas_type_groups/new
  # GET /meas_type_groups/new.xml
  def new
    @meas_type_group = MeasTypeGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meas_type_group }
    end
  end

  # GET /meas_type_groups/1/edit
  def edit
    @meas_type_group = MeasTypeGroup.find(params[:id])
  end

  # POST /meas_type_groups
  # POST /meas_type_groups.xml
  def create
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
