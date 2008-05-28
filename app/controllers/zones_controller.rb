class ZonesController < ApplicationController
  
  require_role [ "admin", "owner" ]
  
  def index
    @zones = Zone.find(
      :all,
      :user => current_user,
      :limit => 20,
      :order => 'created_at DESC'
    )
  end
  
  def show
    @zone = Zone.find( params[:id], :include => :records )
  end
  
  def new
    @zone = Zone.new
    @zone_templates = ZoneTemplate.find( :all )
  end
  
  def create
    @zone = Zone.new( params[:zone] )
    @zone.user = current_user unless current_user.has_role?( 'admin' )
    
    if @zone.save
      flash[:info] = "Zone created"
      redirect_to zone_path( @zone )
    else
      @zone_templates = ZoneTemplate.find( :all )
      render :action => :new
    end
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
end
