class TemplatesController < ApplicationController
  
  require_role "admin"
  
  def index
    @zone_templates = ZoneTemplate.find( :all, :order => 'name' )
  end
  
  def show
    @zone_template = ZoneTemplate.find(params[:id])
    @record_template = RecordTemplate.new
  end
  
  def new
    @zone_template = ZoneTemplate.new
    render :action => :form
  end
  
  def edit
    @zone_template = ZoneTemplate.find(params[:id])
    render :action => :form
  end
  
  def create
    @zone_template = ZoneTemplate.new(params[:zone_template])
    if @zone_template.save
      flash[:info] = 'Zone Template was created!'
      redirect_to :action => 'index'
      redirect_to template_path( @zone_template )
    end
    render :action => :form
  end
  
  def update
    if @zone_template.update_attributes(params[:zone_template])
      flash[:info] = 'Zone Template was updated!'
      redirect_to template_path
    end
    render :action => :form
  end
  
  def destroy
    @zone_template.delete!
    redirect_to template_path
  end
  
end
