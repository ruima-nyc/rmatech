require 'hpricot'
require 'open-uri'
require 'pp'
require 'rpx'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

    include AuthenticatedSystem
    before_filter :rpx_setup

  before_filter :prepare_for_mobile
  before_filter :login_from_cookie



  caches_action :site_index, :footer_content, :if => Proc.new{|c| c.cache_action? }
  def cache_action?
    !logged_in? && controller_name.eql?('base') && params[:format].blank?
  end



  def admin_required
    current_user && current_user.admin? ? true : access_denied
  end



  def require_current_user
    @user ||= User.find(params[:user_id] || params[:id] )
    unless admin? || (@user && (@user.eql?(current_user)))
      redirect_to :controller => 'sessions', :action => 'new' and return false
    end
    return @user
  end

  protected
    def require_admin
      unless admin?
        redirect_to :controller => 'sessions', :action => 'new' and return false
      end
    end


   def rpx_setup
    unless Object.const_defined?(:API_KEY) && Object.const_defined?(:BASE_URL) && Object.const_defined?(:REALM)
      render :template => 'const_message'
      return false
    end
    @rpx = Rpx::RpxHelper.new(API_KEY, BASE_URL, REALM)
    return true
  end



def mobile_device?
  if session[:mobile_param]
    session[:mobile_param] == "1"
  else
    request.user_agent =~ /Mobile|webOS/
  end
end

helper_method :mobile_device?

def prepare_for_mobile
  session[:mobile_param] = params[:mobile] if params[:mobile]
end

end
