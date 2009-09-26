class SearchController < ApplicationController

  def results
    if params[:q].chomp.blank?
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { render :status => 404, :json => { :error => "Missing 'q' parameter" } }
      end
    else
      @results = Domain.search(params[:q], params[:page], current_user)

      respond_to do |format|
        format.html do
          if @results.size == 1
            redirect_to domain_path(@results.pop)
          end
        end
        format.json do
          render :json => @results.to_json(:only => [:id, :name])
        end
      end
    end
  end

end
