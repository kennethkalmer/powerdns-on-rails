class DashboardController < ApplicationController

  def index
    @latest_domains = Domain.user(current_user).order('created_at DESC').limit(5)
    @zone_templates = ZoneTemplate.with_soa.user( current_user )
    @domain = Domain.new
  end
end
