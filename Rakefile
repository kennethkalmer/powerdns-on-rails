# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

PowerdnsOnRails::Application.load_tasks

task :default => [ :spec, :cucumber ]
task :ci => [ :spec, :cucumber ]
