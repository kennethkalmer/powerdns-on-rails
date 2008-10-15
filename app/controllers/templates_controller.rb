class TemplatesController < ApplicationController
  
  require_role ["admin", "owner"]
  
  before_filter :load_zone, :only => [ :show, :edit, :update, :destroy ]
  
  def index
    @zone_templates = ZoneTemplate.find( :all, :order => 'name', :user => current_user )
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @zone_templates.to_xml }
    end
  end
  
  def show
    @record_template = RecordTemplate.new( :record_type => 'A' )
  end
  
  def new
    @zone_template = ZoneTemplate.new
    
    # load the owners if this is an admin
    @users = User.find(:all).select{ |u| u.has_role?('owner') } if current_user.admin?
    
    render :action => :form
  end
  
  def edit
    @zone_template = ZoneTemplate.find(params[:id])
    @users = User.active_owners if current_user.admin?
    render :action => :form
  end
  
  def create
    @zone_template = ZoneTemplate.new(params[:zone_template])
    @zone_template.user = current_user unless current_user.admin?
    
    if @zone_template.save
      flash[:info] = 'Zone template created'
      redirect_to zone_template_path( @zone_template )
      return
    end
    render :action => :form
  end
  
  def update
    if @zone_template.update_attributes(params[:zone_template])
      flash[:info] = 'Zone template updated'
      redirect_to zone_template_path( @zone_template )
      return
    end
    render :action => :form
  end
  
  def destroy
    @zone_template.destroy
    redirect_to zone_templates_path
  end
  
  private
  
  def load_zone
    @zone_template = ZoneTemplate.find(params[:id])
  end
end
