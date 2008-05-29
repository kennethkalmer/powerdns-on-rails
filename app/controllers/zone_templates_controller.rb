class ZoneTemplatesController < ApplicationController
  
  require_role "admin"
  
  def new
    @zone_template = ZoneTemplate.new
  end
  
  def create
    @zone_template = ZoneTemplate.new(params[:zone_template])
    if @zone_template.save
      redirect_to :controller => :templates, :action => :index
    else
      redirect_to :action => 'new'
    end
  end
  
  def edit
    @zone_template = ZoneTemplate.find(params[:id])
  end
  
  def update
    @zone_template = ZoneTemplate.find(params[:id])
    if @zone_template.update_attributes(params[:zone_template])
      redirect_to :controller => :templates, :action => :index
    else
      redirect_to :action => 'edit'
    end
  end
  
  def destroy
    @zone_template = ZoneTemplate.find(params[:id])
    @zone_template.destroy
    redirect_to templates_path
  end
  
end