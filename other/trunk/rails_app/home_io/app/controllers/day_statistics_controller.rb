class DayStatisticsController < ApplicationController
  # GET /day_statistics
  # GET /day_statistics.xml
  def index
    @day_statistics = DayStatistic.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @day_statistics }
    end
  end

  # GET /day_statistics/1
  # GET /day_statistics/1.xml
  def show
    @day_statistic = DayStatistic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @day_statistic }
    end
  end

end
