class MeasTypeGroupGraphsController < ApplicationController
  def show
    if params[:start]
      @graph = GraphTask.new(params, session)
      puts "Starting GraphTask"
      @job = Delayed::Job.enqueue(@graph)
      @graph.delayed_job_id = @job.id
    end
  end

  def show_old
    t = Time.now
    @meas_type_group_graph = GraphTask.find(params, current_user)
    @process_time = Time.now - t

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meas_type_group_graph }
      format.png  { send_data(@meas_type_group_graph[:graph], :type => 'image/png', :disposition => 'inline') }
    end
  end
end
