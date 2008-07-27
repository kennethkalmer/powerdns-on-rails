class SearchController < ApplicationController
  
  def results
    if params[:q].blank?
      redirect_to root_path
    else
      @results = Domain.search(params[:q], params[:page], current_user)
    end
  end
  
end
