class ReportsController < ApplicationController
  require_role ["admin"]
  
  # search for a specific user
  def index
    @users = User.find_owners(params[:page]).sort
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
