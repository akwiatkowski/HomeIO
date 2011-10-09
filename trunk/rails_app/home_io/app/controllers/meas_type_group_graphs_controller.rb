class MeasTypeGroupGraphsController < ApplicationController
  def show
    t = Time.now
    @meas_type_group_graph = MeasTypeGroupGraph.find(params, current_user)
    @process_time = Time.now - t

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_type_group_graph }
      format.png  { send_data(@meas_type_group_graph[:graph], :type => 'image/png', :disposition => 'inline') }
    end
  end
end
