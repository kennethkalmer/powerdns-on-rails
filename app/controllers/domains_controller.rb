class DomainsController < ApplicationController
  
  require_role [ "admin", "owner" ]
  
  def index
    @domains = Domain.paginate :page => params[:page], :user => current_user, :order => 'name'
  end
  
  def show
    @domain = Domain.find( params[:id], :include => :records )
    @record = @domain.records.new
    
    @users = User.active_owners
  end
  
  def new
    @domain = Domain.new
    @zone_templates = ZoneTemplate.find( :all, :require_soa => true, :user => current_user )
  end
  
  def create
    @zone_template = ZoneTemplate.find(params[:domain][:zone_template_id]) unless params[:domain][:zone_template_id].blank?
    @zone_template ||= ZoneTemplate.find_by_name(params[:domain][:zone_template_name]) unless params[:domain][:zone_template_name].blank?
    
    unless @zone_template.nil?
      @domain = @zone_template.build( params[:domain][:name] )
    else
      @domain = Domain.new( params[:domain] )
    end
    @domain.user = current_user unless current_user.has_role?( 'admin' )

    respond_to do |format|
      if @domain.save
        format.html { 
          flash[:info] = "Domain created"
          redirect_to domain_path( @domain ) 
        }
        format.xml { render :xml => @domain, :status => :created, :location => domain_url( @domain ) }
      else
        format.html {
          @zone_templates = ZoneTemplate.find( :all )
          render :action => :new
        }
        format.xml { render :xml => @domain.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @domain = Domain.find( params[:id] )
  end
  
  def update
    @domain = Domain.find( params[:id] )
    if @domain.update_attributes( params[:domain] )
      flash[:info] = "Domain was updated!"
      redirect_to domain_path(@domain)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @domain = Domain.find( params[:id] )
    @domain.destroy
    redirect_to :action => 'index'
  end
  
  # Non-CRUD methods
  def update_note
    @domain = Domain.find( params[:id] )
    @domain.update_attribute( :notes, params[:domain][:notes] )
  end
  
  def change_owner
    @domain = Domain.find( params[:id] )
    @domain.update_attribute :user_id, params[:domain][:user_id]
  end
end
