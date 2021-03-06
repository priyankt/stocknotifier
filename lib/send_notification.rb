#require 'resque-retry'

class SendNotification
	#extend Resque::Plugins::ExponentialBackoff

	ANDROID_BATCH_LIMIT = 1000

	@queue = :notifyme_send_notification

	# using exponential backoff as required by google gcm
	# it might blacklist of exponential backoff is not used
	#@backoff_strategy = [5, 50, 500, 5000]

	def self.perform(notification_id)

    	notification = Notification.get(notification_id)
    	publisher = notification.publisher

    	# set sent_dttm
    	notification.sent_dttm = DateTime.now
		notification.sent = true
		if notification.valid?
			notification.save
		else
			puts notification.errors.to_hash
		end

    	registration_ids = repository(:default).adapter.select("SELECT registration_token FROM subscribers WHERE publisher_id = #{publisher.id} and active = 1 and registration_token is not null")

    	android_response = ""
    	if publisher.android_api_key.present?
	    	
	    	GCM.key = publisher.android_api_key
			
			data = {message: notification.title}
			total = registration_ids.length
			start = 0

			while start < total
				# minus 1 since starting from 0
				last = [start + (ANDROID_BATCH_LIMIT - 1), total - 1].min
				chunk = registration_ids[start..last]
				response = GCM.send_notification( chunk, data )
				android_response = android_response + response.to_json
				start = last + 1
			end
			
		end

		if publisher.ios_api_key.present?
			# code to send notification to ios
		end

		logger.info android_response

  	end

end