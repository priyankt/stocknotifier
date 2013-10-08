#require 'resque-retry'

class SendEmail
	extend Resque::Plugins::Retry

	@queue = :send_email

	#@retry_limit = 3
  	#@retry_delay = 120

	def self.perform(params)

		case params['mailer_name']
			when 'notifier'
				case params['email_type']
					when 'forgot_passwd_publisher'
						publisher = Publisher.get(params['publisher_id'])
						new_passwd = params['new_passwd']
						StockNotifier::App.deliver(:notifier, :forgot_passwd_publisher, publisher, new_passwd)
					when 'forgot_passwd_subscriber'
						subscriber = Subscriber.get(params['subscriber_id'])
						new_passwd = params['new_passwd']
						StockNotifier::App.deliver(:notifier, :forgot_passwd_subscriber, subscriber, new_passwd, subscriber.publisher)
					when 'new_user'
						subscriber = Subscriber.get(params['subscriber_id'])
						passwd = params['new_passwd']
						StockNotifier::App.deliver(:notifier, :new_user, subscriber, passwd, subscriber.publisher)
					when 'feedback'
						subscriber = Subscriber.get(params['subscriber_id'])
						msg = params['msg']
						StockNotifier::App.deliver(:notifier, :feedback, subscriber, msg)
					else
						puts 'Invalid email type'
				end
		end
		
	end

end