class ZonesController < ApplicationController
  
  require_role [ "admin", "owner" ]
  
  def index
    @zones = Zone.paginate :page => params[:page], :user => current_user, :order => 'name'
  end
  
  def show
    @zone = Zone.find( params[:id], :include => :records )
    @record = @zone.records.new
  end
  
  def new
    @zone = Zone.new
    @zone_templates = ZoneTemplate.find( :all, :require_soa => true, :user => current_user )
  end
  
  def create
    unless params[:zone_template].blank?
      @zone_template = ZoneTemplate.find(params[:zone_template][:id]) unless params[:zone_template][:id].blank?
      @zone_template ||= ZoneTemplate.find_by_name(params[:zone_template][:name]) unless params[:zone_template][:name].blank?
    end
    
    unless @zone_template.nil?
      @zone = @zone_template.build( params[:zone][:name] )
    else
      @zone = Zone.new( params[:zone] )
    end
    @zone.user = current_user unless current_user.has_role?( 'admin' )

    respond_to do |format|
      if @zone.save
        format.html { 
          flash[:info] = "Zone created"
          redirect_to zone_path( @zone ) 
        }
        format.xml { render :xml => @zone, :status => :created, :location => zone_url( @zone ) }
      else
        format.html {
          @zone_templates = ZoneTemplate.find( :all )
          render :action => :new
        }
        format.xml { render :xml => @zone.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @zone = Zone.find( params[:id] )
  end
  
  def update
    @zone = Zone.find( params[:id] )
    if @zone.update_attributes( params[:zone] )
      flash[:info] = "Zone was updated!"
      redirect_to zone_path
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @zone = Zone.find( params[:id] )
    @zone.destroy
    redirect_to :action => 'index'
  end
  
  # Non-CRUD methods
  def update_note
    @zone = Zone.find( params[:id] )
    @zone.update_attribute( :notes, params[:zone][:notes] )
  end
  
end
