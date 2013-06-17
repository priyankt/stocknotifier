class SendEmail

	@queue = :send_email

	def self.perform(params)

		case params['mailer_name']
		when 'notifier'
		case params['email_type']
			when 'forgot_passwd'
				if params['user_type'] == 'publisher'
					user = Publisher.get(params['publisher_id'])
				else
					user = Subscriber.get(params['subscriber_id'])
				end
				new_passwd = params['new_passwd']
				StockNotifier::App.deliver(:notifier, :forgot_passwd, user, new_passwd)
			end
		end
  	end

end