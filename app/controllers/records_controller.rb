class RecordsController < ApplicationController
  
  def new
    @record = Record.new
  end
  
  def create
    @record = Record.new( params[:record] )
    @record.zone_id = @zone.id
    if @record.save
      flash[:info] = "Record created!"
      redirect_to zone_path( @zone )
    else
      render :action => :new
    end
  end
  
  def edit
    @record = Record.find( params[:id] )
  end
  
  def update
    @record = Record.find( params[:id] )
    if @record.update_attributes( params[:record] )
      flash[:info] = "Record udpated!"
      redirect_to zone_path( @zone )
    else
      render :action => :edit
    end
  end
  
  def destroy
    @record = Record.find( params[:id] )
    @record.destroy
    redirect_to zone_path( @zone )
  end
  
  protected
  
  def get_zone
    @zone = Zone.find(params[:zone_id], :user => current_user)
  end
end
