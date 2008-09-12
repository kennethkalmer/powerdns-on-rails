class SearchController < ApplicationController
  
  def results
    if params[:q].chomp.blank?
      redirect_to root_path
    else
      @results = Domain.search(params[:q], params[:page], current_user)
      
      if @results.size == 1
        redirect_to domain_path(@results.pop)
      end
    end
  end
  
end
