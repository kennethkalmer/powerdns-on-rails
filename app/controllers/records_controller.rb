class RecordsController < ApplicationController
  
  require_role [ "admin", "owner" ]
  
  before_filter :get_zone
  
  def new
    @record = @domain.records.new
  end
  
  def create
    @record = @domain.send( "#{params[:record][:type].downcase}_records".to_sym ).new( params[:record] )
    if @record.save
      flash.now[:info] = "Record created!"
    else
      flash.now[:error] = "Record not created!"
      render :action => :new
    end
  end
  
  def edit
    @record = @domain.records.find( params[:id] )
  end
  
  def update
    @record = @domain.records.find( params[:id] )
    if @record.update_attributes( params[:record] )
      flash.now[:info] = "Record udpated!"
    else
      flash.now[:error] = "Record not updated!"
      render :action => :edit
    end
  end
  
  def destroy
    @record = @domain.records.find( params[:id] )
    @record.destroy
    redirect_to domain_path( @domain )
  end
  
  # Non-CRUD methods
  def update_soa
    @domain.soa_record.update_attributes( params[:soa] )
    if @domain.soa_record.valid?
      flash.now[:info] = "SOA record updated!"
    else
      flash.now[:error] = "SOA record not updated!"
    end
  end
  
  protected
  
  def get_zone
    @domain = Domain.find(params[:domain_id], :user => current_user)
  end
end
