set :application, "triton"
set :repository,  "git@github.com:thejoshwolfe/triton"
set :scm, :git

set :user, 'deploy'
set :use_sudo, false

role :web, "triton.royvandewater.com"                      # Your HTTP server, Apache/etc
role :app, "triton.royvandewater.com"                      # This may be the same as your `Web` server
role :db,  "triton.royvandewater.com", :primary => true    # This is where Rails migrations will run

set :deploy_to, '/home/deploy/apps/triton'

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :finalize_update do
  end

  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
