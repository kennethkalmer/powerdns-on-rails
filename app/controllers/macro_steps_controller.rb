class MacroStepsController < InheritedResources::Base

  belongs_to :macro
  respond_to :xml, :json, :js

  protected

  def parent
    Macro.user( current_user ).find( params[:macro_id] )
  end

  def collection
    parent.macro_steps
  end

  def resource
    collection.find( params[:id] )
  end

  public

  def create
    # Check for any previous macro steps
    if parent.macro_steps.any?
      # Check for the parameter
      unless params[:macro_step][:position].blank?
        position = params[:macro_step].delete(:position)
      else
        position = parent.macro_steps.last.position + 1
      end
    else
      position = '1'
    end

    @macro_step = parent.macro_steps.create( params[:macro_step] )

    @macro_step.insert_at( position ) if position && !@macro_step.new_record?

    if parent.save
      flash.now[:info] = t(:message_macro_step_created)
    else
      flash.now[:error] = t(:message_macro_step_cannot_create)
    end
  end

  def update
    position = params[:macro_step].delete(:position)

    @macro_step = parent.macro_steps.find( params[:id] )
    @macro_step.update_attributes( params[:macro_step] )

    @macro_step.insert_at( position ) if position

    respond_to do |wants|
      wants.js
    end
  end

  def destroy
    @macro_step = parent.macro_steps.find( params[:id] )
    @macro_step.destroy

    flash[:info] = t :message_macro_step_removed
    redirect_to macro_path( parent )
  end

end
