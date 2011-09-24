class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    # not pretty but works
    session[:mobile] = params[:user_session][:mobile] == '1'
    if @user_session.save
      flash[:notice] = "Login successful!"
      #redirect_back_or_default account_url
      redirect_back_or_default meas_caches_path
    else
      render :action => :new
    end
  end

  def show
    
  end

  def logout
    # problems with delete method
    destroy
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

end