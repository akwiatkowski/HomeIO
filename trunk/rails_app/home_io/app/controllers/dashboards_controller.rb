class DashboardsController < ApplicationController
  # GET /dashboards
  # GET /dashboards.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => nil }
    end
  end

  # GET /dashboards/1
  # GET /dashboards/1.xml
  def show
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => nil }
    end
  end
end
