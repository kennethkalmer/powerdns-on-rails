class ContentController < ApplicationController
  def domains
    @domains = Domain.where("user_id is not null").order("name")
  end
end
