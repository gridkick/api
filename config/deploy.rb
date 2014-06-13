require 'capistrano/ext/multistage'

##
# Plugins
#
require 'airbrake/capistrano'
require 'bundler/capistrano'
require 'rvm/capistrano'
require 'sidekiq/capistrano'

set :application                , 'adventure-api'
set :default_run_options        , :pty => true
set :default_stage              , 'staging'
set :deploy_via                 , :remote_cache
set :normalize_asset_timestamps , false
set :repository                 , 'git@github.com:venture-io/adventure_api.git'
set :rvm_ruby_string            , 'ruby-2.0.0-p353'
set :scm                        , :git
set :stages                     , [ 'production' , 'staging' , 'local' ]
set :use_sudo                   , false

ssh_options[ :forward_agent ] = true

namespace :deploy do
  task :create_deploy_to_location do
    "mkdir -p #{ deploy_to }"
  end

  task :start, :roles => :app do
    passenger.restart
  end

  task :stop, :roles => :app do; end

  task :restart, :roles => :app do
    passenger.restart
  end

  task :update_deploy_to_permissions do
    "chown -hR #{ user }:root #{ deploy_to }"
  end
end

namespace :passenger do
  task :restart do
    run "touch #{ release_path }/tmp/restart.txt"
  end
end

before 'deploy:setup', 'deploy:create_deploy_to_location'
after 'deploy:setup', 'deploy:update_deploy_to_permissions'
