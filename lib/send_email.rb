class SendEmail

	@queue = :send_email

	def self.perform(mailer_name, email_type, params)

		case mailer_name
		when :notifier
		  case email_type
		  when :forgot_passwd
		  	subscriber = Subscriber.get(params[:subscriber_id])
		  	new_passwd = params[:new_passwd]
		  	StockNotifier::App.deliver(:notifier, :forgot_passwd, subscriber, new_passwd)
		  end
		else
		  puts "Invalid mailer name #{mailer_name} in resque."
		end
  	end

end