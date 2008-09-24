class AuditsController < ApplicationController
  
  require_role "admin"
  
  def index
    
  end
  
  # Retrieve the audit details for a domain
  def domain
    @domain = Domain.find( 
      params[:id], 
      :user => current_user
    )
  end
  
end
