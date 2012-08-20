source 'http://rubygems.org'

gem 'rails', '3.0.9' #TODO

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

platforms :ruby do
  gem 'pg', '>= 0.9.0'
  gem 'therubyracer'
end

gem 'haml'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.0.3'
gem "audited-activerecord", "~> 3.0.0.rc2"
gem 'inherited_resources'
gem 'devise'
gem 'rabl'

gem 'acts_as_list'
gem 'state_machine'

group :development, :test do
  gem "rspec-rails"
  gem 'RedCloth', '>= 4.1.1'
end

group :test do
  if RUBY_VERSION < "1.9"
    gem 'ruby-debug'
  else
    gem 'ruby-debug19'
  end
  gem "factory_girl_rails", "~> 3.0" #TODO: 4.0

  gem "cucumber-rails", :require => false
  gem 'mocha', :require => false
  gem 'webrat'
  gem 'database_cleaner'
end
