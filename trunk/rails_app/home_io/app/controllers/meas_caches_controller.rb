class MeasCachesController < ApplicationController
  def show
    @meas_type = MeasType.find(params[:meas_type_id])

    begin
      meas_json = JSON.parse(Net::HTTP.get(URI.parse("http://localhost:8080/meas_cache/#{@meas_type.name}")))

      @meas_archives = Array.new

      puts meas_json.to_yaml

      meas_json.each do |m|
        ma = MeasArchive.new
        ma.time_from = m["time"]
        ma.time_to = m["time"]
        ma.raw = m["raw"]
        ma.value = m["value"]
        #ma.time_from = m[:time"]
        ma.meas_type = @meas_type
        ma.readonly!

        @meas_archives << ma
      end
    rescue Errno::ECONNREFUSED => e
      @meas_archives = Array.new
      @offline = true
      flash[:warning] = "No active backend connection. Cache not available."
    end

    @meas_archives = @meas_archives.paginate(:page => 1, :per_page => @meas_archives.size)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @meas_archives }
      format.json_graph  { render :json => MeasArchive.to_json_graph( @meas_archives ) }
    end
  end

end
