class RecordsController < ApplicationController

  require_role [ "admin", "owner" ], :unless => "token_user?"

  before_filter :load_domain
  before_filter :load_record, :except => [ :create ]
  before_filter :restrict_token_movements, :except => [:create, :update, :destroy]

  def create
    @record = @domain.send( "#{params[:record][:type].downcase}_records".to_sym ).new( params[:record] )

    if current_token && !current_token.allow_new_records? &&
        !current_token.can_add?( @record )
      render :text => t(:message_token_not_authorized), :status => 403
      return
    end

    if @record.save
      # Give the token the right to undo what it just did
      if current_token
        current_token.can_change @record
        current_token.remove_records = true
        current_token.save
      end
    end

    respond_to do |wants|
      wants.js
    end
  end

  def update
    @record = @domain.records.find( params[:id] )

    if current_token && !current_token.can_change?( @record )
      render :text => t(:message_token_not_authorized), :status => 403
      return
    end

    @record.update_attributes( params[:record] )

    respond_to do |wants|
      wants.js
    end
  end

  def destroy
    if current_token && !current_token.can_remove?( @record )
      render :text => t(:message_token_not_authorized), :status => 403
      return
    end

    @record.destroy

    respond_to do |format|
      format.html { redirect_to domain_path( @domain ) }
      format.xml { head :ok }
    end
  end

  # Non-CRUD methods
  def update_soa
    if current_token
      render :text => t(:message_token_not_authorized), :status => 403
      return
    end

    @domain.soa_record.update_attributes( params[:soa] )
    if @domain.soa_record.valid?
      flash.now[:info] = t(:message_record_soa_updated)
    else
      flash.now[:error] = t(:message_record_soa_not_updated)
    end

    respond_to do |wants|
      wants.js
    end
  end

  protected

  def load_domain
    @domain = Domain.find(params[:domain_id], :user => current_user)

    if current_token && @domain != current_token.domain
      render :text => t(:message_token_not_authorized), :status => 403
      return false
    end
  end

  def load_record
    @record = @domain.records.find( params[:id] )
  end

  def restrict_token_movements
    return unless current_token
    
    render :text => t(:message_token_not_authorized), :status => 403
    return false
  end
end
