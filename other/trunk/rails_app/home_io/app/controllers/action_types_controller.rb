class ActionTypesController < ApplicationController
  # GET /action_types
  # GET /action_types.xml
  def index
    authorize! :read, ActionType
    @action_types = ActionType.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @action_types }
    end
  end

  # GET /action_types/1
  # GET /action_types/1.xml
  def show
    authorize! :read, ActionType
    @action_type = ActionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @action_type }
    end
  end

  # GET /action_types/1/edit
  def edit
    authorize! :manage, ActionType
    @action_type = ActionType.find(params[:id])
  end

  # GET /action_types/1/execute
  def execute
    @action_type = ActionType.find(params[:id])
    authorize! :execute, @action_type

    status = BackendProtocol.execute_action(@action_type.name, current_user.id)

    if status
      flash[:notice] = "Action was executed"
    else
      flash[:notice] = "Action execution failed!"
    end

    redirect_to action_type_action_events_path(@action_type)
  end



  # PUT /action_types/1
  # PUT /action_types/1.xml
  def update
    authorize! :manage, ActionType
    @action_type = ActionType.find(params[:id])

    respond_to do |format|
      if @action_type.update_attributes(params[:action_type])
        format.html { redirect_to(@action_type, :notice => 'Action type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @action_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  # GET /action_types/new
  # GET /action_types/new.xml
  def new
    authorize! :read, ActionType
    @action_type = ActionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @action_type }
    end
  end

  # POST /action_types
  # POST /action_types.xml
  def create
    return # not in rails
    authorize! :manage, ActionType

    @action_type = ActionType.new(params[:action_type])

    respond_to do |format|
      if @action_type.save
        format.html { redirect_to(@action_type, :notice => 'Action type was successfully created.') }
        format.xml  { render :xml => @action_type, :status => :created, :location => @action_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @action_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /action_types/1
  # DELETE /action_types/1.xml
  def destroy
    return # not in rails
    authorize! :manage, ActionType
    
    @action_type = ActionType.find(params[:id])
    @action_type.destroy

    respond_to do |format|
      format.html { redirect_to(action_types_url) }
      format.xml  { head :ok }
    end
  end
end
