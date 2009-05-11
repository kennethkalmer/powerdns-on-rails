class AuthTokensController < ApplicationController
  
  require_role 'auth_token'
  
  # Create a new #AuthToken. See #AuthToken for the finer details on
  # how authentication tokens work.
  #
  # Expects an XML POST to /auth_token.xml with the following
  # information:
  #
  #   <auth_token>
  #     <domain>name</domain>
  #     <expires_at>RFC822 timestamp</expires_at>
  #     <policy>token policy</policy>
  #     <allow_new>true/false</allow_new>
  #     <remove>true</false>
  #     <!-- record tag for each record -->
  #     <record>...</record>
  #     <record>...</record>
  #     <!-- protect_type tag for each type to be protected -->
  #     <protect_type>...</protect_type>
  #     <protect_type>...</protect_type>
  #     <!-- protect tag for each record to protect -->
  #     <protect>...</protect>
  #   </auth_token>
  #
  # Returns the following when successful:
  #
  #   <token>
  #     <url>...</url>
  #     <auth_token>...</auth_token>
  #     <expires>...</expires>
  #   </token>
  #
  # Or on failure:
  #
  #   <error>Message</error>
  #
  def create
    if params[:auth_token].blank?
      render :status => 422, :xml => <<-EOS
<error>#{t(:message_token_missing_parametr)}</error>
EOS
      return false
    end
    
    # Get our domain
    domain = Domain.find_by_name( params[:auth_token][:domain] )
    if domain.nil?
      render :text => t(:message_domain_not_found), :status => 404
      return
    end
    
    # expiry time
    t = Time.parse( params[:auth_token][:expires_at] || '' )
    
    # Our new token
    @auth_token = AuthToken.new( 
      :domain => domain, 
      :user => current_user, 
      :expires_at => t
    )
    
    # Build our token from here on
    @auth_token.policy = params[:auth_token][:policy] unless params[:auth_token][:policy].blank?
    @auth_token.allow_new_records = ( params[:auth_token][:allow_new] == "true" ) unless params[:auth_token][:allow_new].blank?
    @auth_token.remove_records = ( params[:auth_token][:remove] == "true" ) unless params[:auth_token][:remove].blank?
    
    if params[:auth_token][:protect_type] && params[:auth_token][:protect_type].size > 0
      params[:auth_token][:protect_type].each do |t|
        @auth_token.protect_type( t )
      end
    end
    
    if params[:auth_token][:record] && params[:auth_token][:record].size > 0
      params[:auth_token][:record].each do |r|
        name, type = r.split(':')
        @auth_token.can_change( name, type || '*' )
      end
    end
    
    if params[:auth_token][:protect] && params[:auth_token][:protect].size > 0
      params[:auth_token][:protect].each do |r|
        name, type = r.split(':')
        @auth_token.protect( name, type || '*' )
      end
    end
    
    if @auth_token.save
      render :status => 200, :xml => <<-EOF
        <token>
          <expires>#{@auth_token.expires_at}</expires>
          <auth_token>#{@auth_token.token}</auth_token>
          <url>#{token_url( :token => @auth_token.token )}</url>
        </token>
      EOF
    else
      render :status => 500, :xml => <<-EOF
        <error>
          #{@auth_token.errors.to_xml}
        </error>
      EOF
    end
  end
  
end
