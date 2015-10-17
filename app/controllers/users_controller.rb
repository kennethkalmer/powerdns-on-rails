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

  private

  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation, :admin, :auth_tokens)
  end

end
