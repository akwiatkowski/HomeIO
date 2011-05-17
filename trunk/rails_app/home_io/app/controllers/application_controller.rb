class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all
  helper_method :current_user_session, :current_user

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # When there is no direct connection to backend when it is preferred
  def no_direct_connection_to_backend
    @offline = true
    flash[:warning] = "No active backend connection. Measurements can be not fresh."
  end

  # when user has no proper rights
  rescue_from CanCan::AccessDenied do |exception|
    #redirect_to root_url, :alert => exception.message
    flash[:error] = "You are not authorized"
    redirect_to root_url, :alert => exception.message
  end
end
