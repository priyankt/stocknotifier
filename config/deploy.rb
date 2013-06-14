require "bundler/capistrano"

set :domain, "notifyme.in"
set :application, "notifyme"
set :deploy_to, "/home/web/#{application}"

# You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :scm, :git # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :repository,  "git@github.com:priyankt/stocknotifier.git"
set :branch, 'master'
set :git_shallow_clone, 1

set :user, "web"
set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
	task :start do ; end
	task :stop do ; end
	# Assumes you are using Passenger
	task :restart, :roles => :app, :except => { :no_release => true } do
		run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
	end
	 
	task :finalize_update, :except => { :no_release => true } do
		run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
		 
		# mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
		run <<-CMD
		rm -rf #{latest_release}/log &&
		mkdir -p #{latest_release}/public &&
		mkdir -p #{latest_release}/tmp &&
		ln -s #{shared_path}/log #{latest_release}/log
		CMD
		 
		# if fetch(:normalize_asset_timestamps, true)
		# 	stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
		# 	asset_paths = %w(images css).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
		# 	run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
		# end
	end
end

# after 'deploy:update_code', 'deploy:symlink_db'
 
# namespace :deploy do
# 	desc "Symlinks the database.rb"
# 	task :symlink_db, :roles => :app do
# 		run "ln -nfs #{deploy_to}/shared/config/database.rb #{release_path}/config/database.rb"
# 	end
# end

namespace :gems do
  	task :install do
    	run "cd #{deploy_to}/current && RAILS_ENV=production bundle install"
  	end
end

namespace :database do
  	task :upgrade do
    	run "cd #{deploy_to}/current && padrino rake dm:auto:upgrade -e production"
  	end
end

after :deploy, "gems:install", "database:upgrade"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end