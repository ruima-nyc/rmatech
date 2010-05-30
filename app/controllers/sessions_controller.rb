require 'rpx'

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:rpx_login,:create]
  
  def index
    redirect_to :action => "new"
  end  
  
  # render new.rhtml
  def new
    if params && params[:return]
      session[:return_to] = params[:return]
    else
      session[:return_to] = request.referrer if session[:return_to].nil?
    end
    
    redirect_to ('/') and return if current_user
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      redirect_back_or_default('/')
    else
      flash[:notice] = "登录失败, 请重新尝试登录."
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    #redirect_to new_session_path
    redirect_back_or_default('/')
  end

  def imagecode
		validate_image = ValidateImage.new(4)
		session[:code] = validate_image.code
		send_data(validate_image.code_image, :type => 'image/jpeg')
	end

  def rpx_login
    
    if params[:error] || !params[:token]
      flash[:notice] = "Sign-in cancelled"
      redirect_to :controller => "posts", :action => "index"
      return
    end
    data = @rpx.auth_info(params[:token], request.url)
    @email = data["verifiedEmail"] || data["email"]
    @user_name = data["preferredUsername"] || data["displayName"]
    self.current_user = User.find_by_email(@email)

    if self.current_user
    
      redirect_back_or_default('/')
      return
    elsif @email and @user_name
      @user       = User.new()
      @user.login = @user_name
      @user.email = @email
      @user.passwd = 'qifei'
      if @user.save
        self.current_user = @user
        redirect_back_or_default('/')
      else
        flash[:notice] = "您的用户信息不符合用户名规则，请修改后登录"
      end
    else
      redirect_to :action => "new" and return false
    end
  end
end
