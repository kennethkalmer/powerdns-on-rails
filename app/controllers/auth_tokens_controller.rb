class AuthTokensController < ApplicationController
  
  require_role 'auth_token'
  
  # Only create tokens
  def create
    # Get our domain
    domain = Domain.find_by_name( params[:domain] )
    if domain.nil?
      render :text => 'Domain not found', :status => 404
      return
    end
    
    # expiry time
    t = Time.parse( params[:expires_at] || '' )
    
    # Our new token
    @auth_token = AuthToken.new( 
      :domain => domain, 
      :user => current_user, 
      :expires_at => t
    )
    
    # Build our token from here on
    @auth_token.policy = params[:policy] unless params[:policy].blank?
    @auth_token.allow_new_records = ( params[:allow_new] == "true" ) unless params[:allow_new].blank?
    @auth_token.remove_records = ( params[:remove] == "true" ) unless params[:remove].blank?
    
    if params[:protect_types] && params[:protect_types].size > 0
      params[:protect_types].each do |t|
        @auth_token.protect_type( t )
      end
    end
    
    if params[:records] && params[:records].size > 0
      params[:records].each do |r|
        name, type = r.split(':')
        @auth_token.can_change( name, type || '*' )
      end
    end
    
    if params[:protect] && params[:protect].size > 0
      params[:protect].each do |r|
        name, type = r.split(':')
        @auth_token.protect( name, type || '*' )
      end
    end
    
    if @auth_token.save
      render :status => 200, :text => <<-EOF
        <token>
          <expires>#{@auth_token.expires_at}</expires>
          <auth_token>#{@auth_token.token}</auth_token>
          <url>#{token_url( :token => @auth_token.token )}</url>
        </token>
      EOF
    else
      render :status => 500, :text => <<-EOF
        <error>
          #{@auth_token.errors.to_xml}
        </error>
      EOF
    end
  end
  
end
