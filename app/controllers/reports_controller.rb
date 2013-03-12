class ReportsController < ApplicationController

  before_filter do
    unless current_user.admin?
      redirect_to root_url
    end
  end

  # search for a specific user
  def index
    @users = User.where(:admin => false).paginate(:page => params[:page])
    @total_domains  = Domain.count
    @system_domains = Domain.where('user_id IS NULL').count
  end

  def results
    if params[:q].chomp.blank?
      redirect_to reports_path
    else
      @results = User.search(params[:q], params[:page])
    end
  end

  def view
    @user = User.find(params[:id])
  end
end
