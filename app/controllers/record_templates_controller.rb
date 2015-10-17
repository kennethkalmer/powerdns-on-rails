class RecordTemplatesController < ApplicationController

  def create
    @zone_template = ZoneTemplate.find(params[:zone_template][:id])
    @record_template = RecordTemplate.new( record_template_params )
    @record_template.zone_template = @zone_template
    @record_template.save

    respond_to do |format|
      format.js
    end
  end

  def update
    @record_template = RecordTemplate.find(params[:id])

    @record_template.update_attributes( record_template_params )

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

  private

  def record_template_params
    params.require(:record_template).permit(:retry, :primary_ns, :contact, :refresh, :minimum, :expire, :record_type)
  end

end
