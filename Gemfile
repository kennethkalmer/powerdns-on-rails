source 'https://rubygems.org'

# dotenv-rails >= 2.0 now only supports Rails 4
gem "dotenv", '1.0.2', :require => false
gem 'rails', '~> 3.2.22'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

platforms :ruby do
  gem 'mysql2', '~> 0.3.11'
  # gem 'pg', '>= 0.9.0'
  # gem 'sqlite3'
end

gem 'haml-rails'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.0.4'
gem "audited-activerecord", "~> 3.0.0.rc2"
gem 'inherited_resources'
gem 'devise', '~> 2.2.8'
gem "devise-encryptable"
gem 'rabl'
gem 'state_machine'

gem 'acts_as_list'
gem 'dynamic_form'

group :development do
  gem 'debugger', :platform => :mri_19
  #gem 'RedCloth', '>= 4.1.1'
end

group :development, :test do
  gem 'therubyracer'
  gem "rspec-rails"
  gem 'RedCloth', '>= 4.1.1'
end

group :test do
  gem "factory_girl_rails", "~> 4.0"

  gem "cucumber-rails", :require => false
  gem 'mocha', :require => false
  gem 'webrat'
  gem 'database_cleaner'
end
