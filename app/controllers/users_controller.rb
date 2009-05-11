class UsersController < ApplicationController
  
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :show, :edit, :update]
  require_role "admin"

  def index
    @users = User.find( :all, :order => 'login' )
  end
  
  def show
  end
  
  def new
    @user = User.new
    render :action => :form
  end

  def create
    @user = User.new( params[:user] )
    if @user.save
      # add our roles
      @user.roles << if @user.admin?
        r = [ Role.find_by_name('admin') ]
        if params[:token_user] && params[:token_user] == "1"
          r << Role.find_by_name('auth_token')
        end
        r
      else
        Role.find_by_name('owner')
      end
      
      flash[:info] = t(:message_user_created)
      redirect_to user_path( @user )
      return
    end
    
    render :action => :form
  end
  
  def edit
    render :action => :form
  end
  
  def update
    # strip out blank params
    params[:user].delete_if { |k,v| v.blank? }
    
    if @user.update_attributes( params[:user] )
      # update our roles
      @user.roles.clear
      @user.roles << if @user.admin
        r = [ Role.find_by_name('admin') ]
        if params[:token_user] && params[:token_user] == "1"
          r << Role.find_by_name('auth_token')
        end
        r
      else
        Role.find_by_name('owner')
      end
      
      flash[:info] = t(:message_user_updated)
      redirect_to user_path( @user )
      return
    end
    
    render :action => :form
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = t(:message_user_activated)
    end
    redirect_back_or_default('/')
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

end
