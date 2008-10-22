class RecordTemplatesController < ApplicationController
  
  require_role ["admin", "owner"]
  
  def create
    @record_template = RecordTemplate.new(params[:record_template])
    @zone_template = ZoneTemplate.find(params[:zone_template][:id])
    @record_template.zone_template = @zone_template
    if @record_template.save
      flash.now[:info] = "Record template created"
    else
      flash.now[:error] = "Record template could not be saved"
    end
  end
  
  def update
    @record_template = RecordTemplate.find(params[:id])
    
    if @record_template.update_attributes(params[:record_template])
      flash.now[:info] = "Record template updated"
    else
      flash.now[:error] = "Record template could not be saved"
    end
  end
  
  def destroy
    @record_template = RecordTemplate.find(params[:id])
    zt = @record_template.zone_template
    @record_template.destroy
    flash[:info] = "Record template removed"
    redirect_to zone_template_path( zt )
  end
  
end
