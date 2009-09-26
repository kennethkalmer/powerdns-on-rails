# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by
  # installing acts_as_authenticates and running 'script/generate authenticated
  # account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module
  # gives you the require_role helpers, and others.
  include RoleRequirementSystem

  # Enable audits
  audit_params = [ Domain ]
  # For my own sanity: This gives us [ A => { :parent => :domain }, NS => { :parent => :domain }, .. ]
  audit_params << Record.record_types.map(&:constantize).inject({}) { |memo, t| memo[t] = { :parent => :domain }; memo }
  audit *audit_params

  Record.configure_audits

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details Uncomment the
  # :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'dc25a2ea6f551d9218bcb5f35625ed5e'

  # All pages require a login...
  before_filter :login_required
end
