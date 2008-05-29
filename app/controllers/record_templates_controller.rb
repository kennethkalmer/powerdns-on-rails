class RecordTemplatesController < ApplicationController
  
  require_role "admin"
  
  def new
    @record_template = RecordTemplate.new  
  end
  
  def create
    @record_template = RecordTemplate.new(params[:record_template])
    @zone_template = ZoneTemplate.find(params[:zone_template][:id])
    @record_template.zone_template = @zone_template
    if @record_template.save
      flash[:info] = "Record Template created!"
      redirect_to templates_path
    else
      redirect_to :action => 'new'
    end
  end
  
  def edit
    @record_template = RecordTemplate.find(params[:id])
  end
  
  def update
    @record_template = RecordTemplate.find(params[:id])
    @zone_template = ZoneTemplate.find(params[:zone_template][:id])
    if @record_template.update_attributes(params[:record_template])
      @record_template.zone_template = @zone_template
      @record_template.save!
      flash[:info] = "Record Template updated!"
      redirect_to templates_path
    else
      redirect_to :action => 'edit'
    end
  end
  
  def destroy
    @record_template = RecordTemplate.find(params[:id])
    @record_template.destroy
    redirect_to templates_path
  end
  
end