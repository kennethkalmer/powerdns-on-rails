class TemplatesController < ApplicationController
  
  require_role "admin"
  
  def index
    @templates = ZoneTemplate.find( :all, :order => 'name' )
    @record_templates = RecordTemplate.find(:all, :include => :zone_template)
  end
  
  def show
  end
  
  def new
    @template = ZoneTemplate.new
    render :action => :form
  end
  
  def create
    @zone_template = ZoneTemplate.new(params[:zone_template])
    if @zone_template.save
      flash[:info] = 'Template was created!'
      redirect_to :action => 'index'
      redirect_to template_path( @zone_template )
    else
      redirect_to :action => 'new'
    end
    render :action => :form
  end
  
  def edit
    @template = ZoneTemplate.find(params[:id])
  end
  
  def update
    @template = ZoneTemplate.find(params[:id])
    if @template.update_attributes(params[:template])
      flash[:info] = 'Template was updated!'
      redirect_to :action => 'index'
    else
      redirect_to :action => 'edit'
    end
  end
  
  def destroy
    @template = ZoneTemplate.find(params[:id])
    @template.destroy
  end
  
end
