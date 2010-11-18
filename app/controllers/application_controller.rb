class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticatedSystem

  # All pages require a login...
  before_filter :login_required

end
