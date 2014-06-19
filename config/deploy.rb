# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'Sittercity_Marketplace'
set :scm, :git     #Default :git
set :repo_url, 'git@github.com:ac21/sittermarketplace.git'

# Set :branch in Stage files (production/staging/etc)
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call   # Default branch is :master

set :deploy_to, '/www/sites/sittermarketplace/'
set :format, :pretty     #Default  :pretty
set :log_level, :info   #Default  :debug
set :pty, true    #Default false


#set :linked_files, %w{config/database.yml config/secrets.yml}  #Default is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}   #default is []
# set :default_env, { path: "/opt/ruby/bin:$PATH" }    # Default is  {}
set :keep_releases, 5   #Default 5


set :user, "ec2-user"
set :ssh_options, { forward_agent: true  }




namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
