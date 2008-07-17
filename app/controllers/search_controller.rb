class SearchController < ApplicationController
  
  def results
    if params[:q].blank?
      redirect_to root_path
    else
      @results = Zone.search(params[:q], params[:page], current_user)
    end
  end
  
end
