source 'http://rubygems.org'

gem 'rails', '~> 3.2.21'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

platforms :ruby do
  gem 'mysql2', '~> 0.3.17'
  gem 'pg', '~> 0.18.1'
  gem 'sqlite3', '~> 1.3.10'
  gem 'therubyracer'
end

gem 'strong_parameters'

gem 'haml-rails'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.0.4'
gem "audited-activerecord", "~> 3.0.0"
gem 'inherited_resources'
gem 'devise', '~> 2.2.8'
gem "devise-encryptable"
gem 'rabl'
gem 'state_machine'

gem 'acts_as_list'
gem 'dynamic_form'

group :development do
  gem 'debugger', :platform => :mri_19
  gem 'guard-rspec', :require => false
  #gem 'RedCloth', '>= 4.1.1'
end

group :development, :test do
  gem "rspec-rails", "~> 2.99.0"
  gem 'RedCloth', '>= 4.1.1'
  gem 'test-unit'
end

group :test do
  gem "factory_girl_rails", "~> 4.0"

  gem "cucumber-rails", :require => false
  gem 'mocha', :require => false
  gem 'webrat'
  gem 'database_cleaner'
end
