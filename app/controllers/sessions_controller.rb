# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  skip_before_filter :login_required, :except => [ :destroy ]

  def show
    render :action => :new
  end

  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])

    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default( session_path )
      flash[:notice] = t(:message_user_logged)
    else
      render :action => 'new'
    end
  end

  def token
    self.current_token = AuthToken.authenticate( params[:token] )
    if token_user?
      redirect_to( domain_path( current_token.domain ) )
    end
  end

  def destroy
    if logged_in?
      self.current_user.forget_me

      cookies.delete :auth_token
    end

    self.current_token.expire if self.current_token
    reset_session

    flash[:notice] = t(:message_user_logout)
    redirect_back_or_default( session_path )
  end
end
