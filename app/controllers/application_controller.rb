class ApplicationController < ActionController::Base

  protect_from_forgery

  # All pages require a login...
  before_filter :authenticate_user!

  # Stub
  def current_token
    p [ :current_token ]
    nil
  end
  helper_method :current_token

  # Stub
  def token_user?
    !!current_token
  end

  helper_method :token_user?
end
