require 'resque-retry'

class SendNotification
	extend Resque::Plugins::ExponentialBackoff

	ANDROID_BATCH_LIMIT = 1000

	@queue = :send_notification

	# using exponential backoff as required by google gcm
	# it might blacklist of exponential backoff is not used
	@backoff_strategy = [5, 50, 500, 5000]

	def self.perform(notification_id)

    	notification = Notification.get(notification_id)
    	publisher = notification.publisher

    	registration_ids = repository(:default).adapter.select("SELECT registration_token FROM subscribers WHERE publisher_id = #{publisher.id} and active = 1 and registration_token is not null")

    	unless publisher.android_api_key.nil?
	    	
	    	GCM.key = publisher.android_api_key
			
			data = {message: notification.title}
			response = GCM.send_notification( registration_ids, data )
			android_response = response.to_json

		end

		unless publisher.ios_api_key.nil?
			# code to send notification to ios
		end

		notification.sent = true
		logger.info android_response
		
		if notification.valid?
			notification.save
		else
			puts notification.errors.to_hash
		end

  	end

end