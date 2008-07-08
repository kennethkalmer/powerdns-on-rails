class SearchController < ApplicationController
  
  def results
    @search_parameters = params[:search][:parameters]
    unless @search_parameters.blank?
      # Search our models
      @zones = Zone.search(@search_parameters)
    else
      redirect_to root_path
    end
  end
  
end
