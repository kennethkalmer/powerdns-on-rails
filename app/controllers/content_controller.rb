class ContentController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def domains
    @domains = Domain.where("user_id is not null").order("name")
  end
end
