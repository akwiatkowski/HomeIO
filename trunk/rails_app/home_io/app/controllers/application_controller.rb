class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all
  helper_method :current_user_session, :current_user

  include AncestorHandling

  private

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

  # Turn off layout on xhr requests
  layout :get_layout

  def get_layout
    if request.xhr?
      nil
    else
      #return 'mobile' if not current_user_session.nil? and current_user_session.mobile
      return 'mobile' if session[:mobile]
      return 'normal'
    end
  end

  # Desktop users has more data in 1 page
  def mobile_pagination_multiplier
    return 1 if session[:mobile]
    return 5
  end


  # when user has no proper rights
  rescue_from CanCan::AccessDenied do |exception|
    #redirect_to root_url, :alert => exception.message
    flash[:error] = "You are not authorized"
    redirect_to root_url, :alert => exception.message
  end

  # Modify mobile flag using params
  before_filter :check_mobile_params_flag

  def check_mobile_params_flag
    session[:mobile] = true if params[:_m] == 't'
    session[:mobile] = false if params[:_m] == 'f'
    return true
  end

  # single access using token
  # https://gist.github.com/298153/68313f894f2c7ceed70cfbad61cbbe3a615cdecc
  def self.inherited(klass)
    super
    klass.extend(ClassMethods)
    class << klass
      attr_accessor :single_access_options
    end
  end

  module ClassMethods
    def single_access_allowed(options=nil)
      self.single_access_options=options
      include(SingleAccessAllowed)
    end
  end

  module SingleAccessAllowed
    def single_access_allowed?
      options=self.class.single_access_options
      return true unless options.kind_of?(Hash)
      return [options[:except]].flatten.compact.index(params[:action].to_sym).nil? if options[:except].present?
      return [options[:only]].flatten.compact.include?(params[:action].to_sym)
    end
  end


  #def self.single_access_allowed
  #  [:index, :show].index(params[:action].to_sym)
  #end

end
