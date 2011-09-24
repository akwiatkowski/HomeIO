class MeasCachesController < ApplicationController
  def index
    authorize! :read, MeasArchive
    begin
      # using direct connection to background
      @meas_archives = BackendProtocol.current_meas
    rescue Errno::ECONNREFUSED => e
      # no active connection to backend
      @meas_archives = MeasArchive.all_types_last_measurements
      no_direct_connection_to_backend
    end

    @meas_archives = @meas_archives.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.txt { render :layout => nil }# index.html.haml
      format.xml { render :xml => @meas_archives }
      #format.json { render :json => @meas_archives }
      format.json { render :json => @meas_archives.to_json(:include => :meas_type) }
    end
  end

  def show
    @meas_type = MeasType.find(params[:meas_type_id])

    begin
      @meas_archives = BackendProtocol.meas_by_name(@meas_type.name)
    rescue Errno::ECONNREFUSED => e
      # no active connection to backend
      @meas_archives = Array.new
      no_direct_connection_to_backend
    end

    # reverse sort
    @meas_archives = @meas_archives.sort{|m,n| n.time_from <=> m.time_from}
    @meas_archives = @meas_archives.paginate(:page => 1, :per_page => @meas_archives.size)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @meas_archives }
      format.json_graph  { render :json => MeasArchive.to_json_graph( @meas_archives ) }
      format.png {
        string = UniversalGraph.process_meas(@meas_archives)
        send_data(string, :type => 'image/png', :disposition => 'inline')
      }
    end
  end

end
