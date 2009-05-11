class MacrosController < ApplicationController

  require_role ['admin', 'owner']
  resource_this

  before_filter :new_step, :only => :show
  
  protected

  def load_macro
    @macro = Macro.find(params[:id], :user => current_user)
  end

  def load_macros
    @macros = Macro.find(:all, :user => current_user)
  end

  def new_macro
    @macro = Macro.new
    # load the owners if this is an admin
    @users = User.find(:all).select{ |u| u.has_role?('owner') } if current_user.admin?
  end

  def new_step
    @macro_step = @macro.macro_steps.new
  end
  
  public
  
  def destroy
    flash[:notice] = t(:message_macro_removed)
    redirect_to macros_path
  end
  
  
end
