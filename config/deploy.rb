# This is a sample capistrano file we use on our staging server in the office

set :application, "bind-dlz-on-rails"
#set :repository,  "git://github.com/kennethkalmer/bind-dlz-on-rails.git"
set :repository, "git@dev.clearplanet.co.za:bind-dlz-on-rails.git"
set :ssh_options, { :forward_agent => true }

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"
#set :deploy_via, :remote_cache

role :app, "192.168.0.242"
role :web, "192.168.0.242"
role :db,  "192.168.0.242", :primary => true

set :user, "bind-dlz-on-rails"

set :rails_env, "development"
set :use_sudo, false
set :restart_via, :run

# Hook into capistrano's events
before "deploy:update_code", "deploy:check"
after  "deploy:symlink", "deploy:copy_configs"
before "deploy:migrate", "deploy:copy_configs"

# Create some tasks related to deployment
namespace :deploy do
  
  desc "Restart the mongrels"
  task :restart do
    run "#{deploy_to}/cluster.sh restart"
  end
  
  desc "Copy our configuration files over the deployed ones"
  task :copy_configs do
     # copy our database config file over
    run "cp -f database.yml #{release_path}/config/"
  end
end