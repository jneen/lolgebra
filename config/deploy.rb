require File.expand_path(File.join(File.dirname(__FILE__), 'railsless-deploy.rb'))
set :application, "lolgebra"

set :scm, :git
set :repository, "git://github.com/jayferd/lolgebra"
set :deploy_to, "/var/src/lolgebra/"

server "dharma", :app, :web, :db, :primary => true
set :user, 'git'
set :use_sudo, false

namespace :deploy do
  task :run_in_current do |bash|
    run "cd #{deploy_to}/current && #{bash}"
  end

  task :start do
    deploy.run_in_current <<-bash
      nohup thin -C config/thin.yml start
    bash
  end

  task :stop do
    deploy.run_in_current <<-bash
      nohup thin -C config/thin.yml stop
    bash
  end

  task :restart do
    deploy.run_in_current <<-bash
      thin -C config/thin.yml restart
    bash
  end
end
