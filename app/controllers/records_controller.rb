class RecordsController < ApplicationController
  
  require_role [ "admin", "owner" ], :unless => "token_user?"
  
  before_filter :get_zone
  before_filter :restrict_token_movements, :except => [:create, :update, :destroy]
  
  def new
    @record = @domain.records.new
  end
  
  def create
    if current_token && !current_token.allow_new_records?
      render :text => 'Token not authorized', :status => 403
      return
    end
    
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
    
    if current_token && !current_token.can_change?( @record )
      render :text => 'Token not authorized', :status => 403
      return
    end
    
    if @record.update_attributes( params[:record] )
      flash.now[:info] = "Record udpated!"
    else
      flash.now[:error] = "Record not updated!"
      render :action => :edit
    end
  end
  
  def destroy
    @record = @domain.records.find( params[:id] )
    
    if current_token && !current_token.remove_records? && 
        !current_token.can_change?( @record )
      render :text => 'Token not authorized', :status => 403
      return
    end
    
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
  
  private
  
  def get_zone
    @domain = Domain.find(params[:domain_id], :user => current_user)
    
    if current_token && @domain != current_token.domain
      render :text => 'Token not authorized', :status => 403
      return false
    end
  end
  
  def restrict_token_movements
    return unless current_token
    
    render :text => 'Token not authorized', :status => 403
    return false
  end
end
