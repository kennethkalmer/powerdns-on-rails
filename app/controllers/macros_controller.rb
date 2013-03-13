class MacrosController < InheritedResources::Base

  protected

  def resource
    @macro = Macro.user( current_user ).find(params[:id])
  end

  def collection
    @macros = Macro.user(current_user)
  end

  public

  def new
    new! do |format|
      format.html { render :action => :edit }
    end
  end

  def create
    create! do |success, failure|
      failure.html { render :action => :edit }
    end
  end

  def create_resource(macro)
    macro.user = macro_owner_from_params
    super
  end

  def update_resource(macro, attributes)
    super
    macro.user = macro_owner_from_params
  end

  protected
  def macro_owner_from_params
    puts params
    current_user.admin? ? User.find(params[:macro][:user_id]) : current_user
  end
end
