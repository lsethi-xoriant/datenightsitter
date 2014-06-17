require "bundler/capistrano"

set :stages, %w(production, staging)
set :default_stage, "staging"
set :application, "Sitter Marketplace"
set :scm, "git"
set :repository, "git@github.com:ac21/sittermarketplace.git"
set :deploy_via, :remote_cache
default_run_options[:pty] = true
set :ssh_options, {:forward_agent => true}
set :user, "ec2-user"
set :use_sudo, false
set :deploy_to, "/www/sites/sittermarketplace/"


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

task :production do
  puts "\n\e[0;31m   ######################################################################"
  puts "   #\n   #       Are you REALLY sure you want to deploy to production?"
  puts "   #\n   #               Enter y/N + enter to continue\n   #"
  puts "   ######################################################################\e[0m\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'

  server "www.paysitter.com", :web, :app, :db, :primary => true

  set :rails_env, 'production'    #set the rails environment
  set :branch, "master"     #set the GIT branch
  set :bundle_flags, "--deployment"
end


task :staging do 
  puts "\n\e[0;31m   ######################################################################"
  puts "   #\n   #       Are you REALLY sure you want to deploy to staging?"
  puts "   #\n   #               Enter y/N + enter to continue\n   #"
  puts "   ######################################################################\e[0m\n"
  proceed = STDIN.gets[0..0] rescue nil
  exit unless proceed == 'y' || proceed == 'Y'

  server "staging.paysitter.com", :web, :app, :db, :primary => true

  set :rails_env, 'staging'    #set the rails environment
  set :branch, "staging"     #set the GIT branch
  set :bundle_flags, "--deployment"
end


namespace :deploy do

  task :migrate_database, :roles => :db, :except => { :no_release => true } do
    run "cd #{release_path}; #{try_sudo} RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(release_path,'tmp','restart.txt')}"
  end

end

before 'deploy:create_symlink', 'deploy:migrate_database'    #if the app loads successfully, then migrate DB