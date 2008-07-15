class SearchController < ApplicationController
  
  def results
    @search_parameter = params[:search][:parameter]
    if @search_parameter.blank?
      redirect_to root_path
    else
      @results = Zone.search(@search_parameter)
    end
  end
  
end
