require 'resque/tasks'
require 'resque_scheduler/tasks'

namespace :resque do
  desc "Load the Application Development for Resque"
  task :setup => :environment do
  	require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'
    
    ENV['QUEUES'] = 'notifyme_send_email,notifyme_send_notification'
    # ENV['VERBOSE']  = '1' # Verbose Logging
    # ENV['VVERBOSE'] = '1' # Very Verbose Logging
  end
end
