class RecordTemplatesController < ApplicationController

  def create
    @record_template = RecordTemplate.new(params[:record_template])
    @zone_template = ZoneTemplate.find(params[:zone_template][:id])
    @record_template.zone_template = @zone_template
    @record_template.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @record_template = RecordTemplate.find(params[:id])

    @record_template.update_attributes(params[:record_template])

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @record_template = RecordTemplate.find(params[:id])
    zt = @record_template.zone_template
    @record_template.destroy

    flash[:info] = t(:message_record_template_removed)
    redirect_to zone_template_path( zt )
  end

end
