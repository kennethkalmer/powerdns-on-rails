class DomainsController < InheritedResources::Base

  # Keep token users in line
  before_filter :restrict_token_movements, :except => :show

  custom_actions :resource => :apply_macro
  respond_to :xml, :json, :js, :html

  protected

  def collection
    @domains = Domain.user( current_user ).paginate :page => params[:page]
  end

  def resource
    @domain = Domain.scoped.includes(:records)

    if current_user
      @domain = @domain.user( current_user ).find( params[:id] )
    else
      @domain = @domain.find( current_token.domain_id )
    end
    @domain
  end

  def restrict_token_movements
    redirect_to domain_path( current_token.domain ) if current_token
  end

  def domain_params
    params.require(:domain).permit(:name, :zone_template_id, :zone_template_name, :primary_ns, :contact, :refresh, :retry, :expire, :minimum, :type, :master)
  end

  public

  def show
    if current_user && current_user.admin?
      @users = User.active_owners
    end

    show!
  end

  def create
    @domain = Domain.new( domain_params )

    unless @domain.slave?
      @zone_template = ZoneTemplate.find(domain_params[:zone_template_id]) unless params[:domain][:zone_template_id].blank?
      @zone_template ||= ZoneTemplate.find_by_name(domain_params[:zone_template_name]) unless params[:domain][:zone_template_name].blank?

      unless @zone_template.nil?
        begin
          @domain = @zone_template.build( domain_params[:name] )
        rescue ActiveRecord::RecordInvalid => e
          @domain.attach_errors(e)

          render :action => :new
          return
        end
      end
    end

    @domain.user = current_user unless current_user.admin?

    create!
  end

  # Non-CRUD methods
  def update_note
    resource.update_attribute( :notes, params[:domain][:notes] )
  end

  def change_owner
    resource.update_attribute :user_id, params[:domain][:user_id]

    respond_to do |wants|
      wants.js
    end
  end

  # GET: list of macros to apply
  # POST: apply selected macro
  def apply_macro
    @domain = resource

    if request.get?
      @macros = Macro.user(current_user)

      respond_to do |format|
        format.html
        format.json
        format.xml
      end

    else
      @macro = Macro.user( current_user ).find( params[:macro_id] )
      @macro.apply_to( resource )

      respond_to do |format|
        format.html {
          flash[:notice] = t(:message_domain_macro_applied)
          redirect_to resource
        }
        format.json { render :status => 202 }
        format.xml { render :status => 202 }
      end

    end

  end

end
