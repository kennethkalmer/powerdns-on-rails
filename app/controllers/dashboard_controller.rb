class DashboardController < ApplicationController

  def index
    @latest_domains = Domain.all( :user => current_user, :order => 'created_at DESC', :limit => 5)
    @zone_templates = ZoneTemplate.all( :require_soa => true, :user => current_user )
    @domain = Domain.new
  end
end
