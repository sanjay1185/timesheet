set :default_stage, "staging"
set :stages, %w(production demo staging)
require 'capistrano/ext/multistage'

set :keep_releases, 3
set :use_sudo, false

set :application, "clockoff"
set :port, 28001

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

default_run_options[:pty] = true
set :repository,  "ssh://git@clockoff.com:28001/home/git/timesheets"
set :scm, "git"
set :user, :opt1
set :branch, "master"
set :deploy_via, :remote_cache

server "clockoff.com", :app, :web, :db, :primary => true

#desc "Restart the web server. Overrides the default task for Site5 use"
#deploy.task :restart, :roles => :app do
#  run "skill -9 -u #{user} -c dispatch.fcgi"
#end

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :files do
  task :move_index do
    run "mv #{current_path}/public/index.html #{current_path}/public/old_index.html"
  end
end

namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "/etc/init.d/apache2 #{action.to_s}", :via => :sudo
    end
  end
end

after "deploy:update", "passenger:restart", "files:move_index"
after "deploy:migrations", "deploy:cleanup"