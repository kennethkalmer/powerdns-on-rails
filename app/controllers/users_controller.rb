class UsersController < InheritedResources::Base

  before_filter do
    unless current_user.admin?
      redirect_to root_url
    end
  end

  def update
    # strip out blank params
    params[:user].delete_if { |k,v| v.blank? }
    update!
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
    resource.suspend!
    redirect_to users_path
  end

  def unsuspend
    resource.unsuspend!
    redirect_to users_path
  end

  def destroy
    resource.delete!
    redirect_to users_path
  end

  def purge
    resource.destroy
    redirect_to users_path
  end

end
