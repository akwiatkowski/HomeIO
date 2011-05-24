class HomeArchivesController < ApplicationController
  # GET /home_archives
  # GET /home_archives.xml
  def index
    authorize! :read, HomeArchive
    @home_archives = HomeArchive.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @home_archives }
    end
  end

  # GET /home_archives/1
  # GET /home_archives/1.xml
  def show
    authorize! :read, HomeArchive
    @home_archive = HomeArchive.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @home_archive }
    end
  end

  # GET /home_archives/new
  # GET /home_archives/new.xml
  def new
    authorize! :create, HomeArchive
    @home_archive = HomeArchive.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @home_archive }
    end
  end

  # GET /home_archives/1/edit
  def edit
    @home_archive = HomeArchive.find(params[:id])
    authorize! :manage, @home_archive
  end

  # POST /home_archives
  # POST /home_archives.xml
  def create
    authorize! :create, HomeArchive
    @home_archive = HomeArchive.new(params[:home_archive])
    @home_archive.user = current_user

    respond_to do |format|
      if @home_archive.save
        format.html { redirect_to(@home_archive, :notice => 'Home archive was successfully created.') }
        format.xml  { render :xml => @home_archive, :status => :created, :location => @home_archive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @home_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /home_archives/1
  # PUT /home_archives/1.xml
  def update
    @home_archive = HomeArchive.find(params[:id])
    authorize! :manage, @home_archive

    respond_to do |format|
      if @home_archive.update_attributes(params[:home_archive])
        format.html { redirect_to(@home_archive, :notice => 'Home archive was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @home_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /home_archives/1
  # DELETE /home_archives/1.xml
  def destroy
    @home_archive = HomeArchive.find(params[:id])
    authorize! :manage, @home_archive
    @home_archive.destroy

    respond_to do |format|
      format.html { redirect_to(home_archives_url) }
      format.xml  { head :ok }
    end
  end
end
