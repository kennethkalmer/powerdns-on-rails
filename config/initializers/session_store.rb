# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_powerdns-on-rails_session',
  :secret      => 'e39886c141ee8bacc6be9c5ef1d4c47693a7613f6b087e04e3ae32a01fa5a6c5c06170e3d85d761f06a0a67a3b0eaec3131f5019ad468af57196e465cd0ded9a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
