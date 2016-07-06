# Your secret key for verifying cookie session data integrity. If you
# change this key, all old sessions will become invalid! Make sure the
# secret is at least 30 characters and all random, no regular words or
# you'll be exposed to dictionary attacks. Do never make this public!
PowerdnsOnRails::Application.config.secret_token = ENV['SECRET_TOKEN']
