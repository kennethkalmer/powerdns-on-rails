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

end
