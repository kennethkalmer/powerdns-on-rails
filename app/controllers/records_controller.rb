class RecordsController < ApplicationController
  
  before_filter :get_zone
  
  def new
    @record = @zone.records.new
  end
  
  def create
    @record = @zone.records.new( params[:record] )
    @record.zone_id = @zone.id
    if @record.save
      flash[:now] = "Record created!"
      redirect_to zone_path( @zone )
    else
      render :action => :new
    end
  end
  
  def edit
    @record = @zone.records.find( params[:id] )
  end
  
  def update
    @record = @zone.records.find( params[:id] )
    if @record.update_attributes( params[:record] )
      flash[:now] = "Record udpated!"
      redirect_to zone_path( @zone )
    else
      render :action => :edit
    end
  end
  
  def destroy
    @record = @zone.records.find( params[:id] )
    @record.destroy
    redirect_to zone_path( @zone )
  end
  
  protected
  
  def get_zone
    @zone = Zone.find(params[:zone_id], :user => current_user)
  end
end
