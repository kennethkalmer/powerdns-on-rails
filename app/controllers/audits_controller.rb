class AuditsController < ApplicationController

  before_filter do
    unless current_user.admin?
      redirect_to root_url
    end
  end

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
