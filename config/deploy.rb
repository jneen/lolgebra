require File.expand_path(File.join(File.dirname(__FILE__), 'railsless-deploy.rb'))
set :application, "lolgebra"

set :scm, :git
set :repository, "git://github.com/jayferd/lolgebra"
set :deploy_to, "/var/src/lolgebra/"

server "dharma", :app, :web, :db, :primary => true
set :user, 'git'
set :use_sudo, false

namespace :deploy do
  [:start, :stop, :restart].each do |action|
    desc "#{action} the Thin processes"
    task action do
      run <<-bash
        /var/lib/gems/1.8/bin/thin #{action} \
          -c #{deploy_to}/current \
          -C #{deploy_to}/current/config/thin.yml
      bash
    end
  end
end
