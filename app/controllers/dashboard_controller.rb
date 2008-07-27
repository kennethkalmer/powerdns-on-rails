class DashboardController < ApplicationController
  
  require_role ["admin", "owner"]
  
  def index
    @latest_domains = Domain.find(:all, :user => current_user, :order => 'created_at DESC', :limit => 3)
    @zone_templates = ZoneTemplate.find( :all, :require_soa => true, :user => current_user )
    @domain = Domain.new
  end
end
