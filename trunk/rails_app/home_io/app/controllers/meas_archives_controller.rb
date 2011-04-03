class MeasArchivesController < ApplicationController
  # GET /meas_archives
  # GET /meas_archives.xml
  def index
    @meas_archives = MeasType.find(params[:meas_type_id]).meas_archives.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @meas_archives }
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
    @meas_archive = MeasArchive.find(params[:id])
    @meas_archive.destroy

    respond_to do |format|
      format.html { redirect_to(meas_archives_url) }
      format.xml { head :ok }
    end
  end
end
