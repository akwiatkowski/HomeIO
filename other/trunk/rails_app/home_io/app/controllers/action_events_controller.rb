class ActionEventsController < ApplicationController
  has_scope :meas_type_id
  has_scope :time_from
  has_scope :time_to

  # GET /action_events
  # GET /action_events.xml
  def index
    authorize! :read, ActionEvent

    #if params[:action_type_id].to_i == 0
    #  # show events for all action types
    #  @action_events = ActionEvent.order("time DESC").paginate(:page => params[:page])
    #else
    #  # show only event for proper type
    #  @action_events = ActionType.find(params[:action_type_id]).action_events.order("time DESC").paginate(:page => params[:page])
    #end

    action_events = apply_scopes(ActionEvent).order("time DESC")

    respond_to do |format|
      format.html { @action_events = action_events.paginate(:page => params[:page], :per_page => 20 * mobile_pagination_multiplier) } # index.html.erb
      format.xml {
        @action_events = action_events.limit(1000)
        render :xml => @action_events
      }
      format.json {
        @action_events = action_events.limit(1000)
        render :json => @action_events
      }
    end
  end

  # GET /action_events/1
  # GET /action_events/1.xml
  def show
    authorize! :read, ActionEvent
    @action_event = ActionEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @action_event }
    end
  end

end
