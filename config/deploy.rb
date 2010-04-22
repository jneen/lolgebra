set :application, "lolgebra"

set :scm, :git
set :repository, "git://github.com/jayferd/lolgebra"
set :deploy_to, "/var/src/lolgebra/"

server "dharma", :app, :web, :db, :primary => true
set :user, 'git'
set :use_sudo, false

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
