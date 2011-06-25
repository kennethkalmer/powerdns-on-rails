class ApplicationController < ActionController::Base

  protect_from_forgery

  # All pages require a login...
  before_filter :authenticate_user!

  # Stub
  def current_token
    nil
  end

  # Stub
  def token_user?
    !!current_token
  end
end
