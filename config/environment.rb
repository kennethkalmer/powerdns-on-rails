require 'dotenv'
# https://github.com/bkeepers/dotenv/issues/19
ENV["RAILS_ENV"] ||= ENV["RACK_ENV"] || "production"
Dotenv.load ".env.#{ENV["RAILS_ENV"]}", '.env'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PowerdnsOnRails::Application.initialize!
