class DashboardController < ApplicationController

  def index
    @latest_domains = Domain.user(current_user).order('created_at DESC').limit(5)
  end
end
