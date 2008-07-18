class DashboardController < ApplicationController
  
  require_role ["admin", "owner"]
  
  def index
    @latest_zones = Zone.find(:all, :user => current_user, :order => 'created_at DESC', :limit => 10)
    @zone_templates = ZoneTemplate.find( :all, :require_soa => true, :user => current_user )
    @zone = Zone.new
  end
end
