class OverseersController < ApplicationController
  # GET /overseers
  # GET /overseers.xml
  def index
    authorize! :read, Overseer
    @overseers = Overseer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @overseers }
    end
  end

  def status
    authorize! :read, Overseer
    @overseer_statuses = BackendProtocol.overseers_list.paginate(:page => params[:page], :per_page => 20)
  end

  # GET /overseers/1
  # GET /overseers/1.xml
  def show
    authorize! :read, Overseer
    @overseer = Overseer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @overseer }
    end
  end

  # GET /overseers/new
  # GET /overseers/new.xml
  def new
    authorize! :create, Overseer
    @overseer = Overseer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @overseer }
    end
  end

  # GET /overseers/1/edit
  def edit
    @overseer = Overseer.find(params[:id])
    authorize! :manage, @overseer
  end

  # POST /overseers
  # POST /overseers.xml
  def create
    authorize! :create, Overseer
    @overseer = Overseer.new(params[:overseer])

    respond_to do |format|
      if @overseer.save
        format.html { redirect_to(@overseer, :notice => 'Overseer was successfully created.') }
        format.xml  { render :xml => @overseer, :status => :created, :location => @overseer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @overseer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /overseers/1
  # PUT /overseers/1.xml
  def update
    @overseer = Overseer.find(params[:id])
    authorize! :manage, @overseer

    respond_to do |format|
      if @overseer.update_attributes(params[:overseer])
        format.html { redirect_to(@overseer, :notice => 'Overseer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @overseer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def disable
    @overseer = Overseer.find(params[:id])
    authorize! :manage, @overseer

    respond_to do |format|
      if @overseer.disable
        format.html { redirect_to({:action => "status"}, :notice => 'Overseer was disabled.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to({:action => "status"}, :error => 'Overseer can not be disabled.') }
        format.xml  { render :xml => @overseer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def enable
    @overseer = Overseer.find(params[:id])
    authorize! :manage, @overseer

    respond_to do |format|
      if @overseer.enable
        format.html { redirect_to({:action => "status"}, :notice => 'Overseer was enabled.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to({:action => "status"}, :error => 'Overseer can not be enabled.') }
        format.xml  { render :xml => @overseer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /overseers/1
  # DELETE /overseers/1.xml
  def destroy
    @overseer = Overseer.find(params[:id])
    authorize! :manage, @overseer
    @overseer.destroy

    respond_to do |format|
      format.html { redirect_to(overseers_url) }
      format.xml  { head :ok }
    end
  end
end
