class TemplatesController < ApplicationController
  
  require_role "admin"
  
  def index
    @templates = ZoneTemplate.find( :all, :order => 'name' )
  end
end
