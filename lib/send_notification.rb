class SendNotification

	ANDROID_BATCH_LIMIT = 1000

	@queue = :send_notification

	def self.perform(notification_id)

    	notification = Notification.get(notification_id)
    	publisher = notification.publisher

    	# send android notifications
    	registration_ids = Subscribers.all(:fields => [:registration_token], :publisher_id => publisher.id, :active => true)

    	if not publisher.android_api_key.empty?
	    	
	    	gcm = GCM.new(publisher.android_api_key)
			options = {data: {message: notification.title} }

			total = registration_ids.length
			start = 0
			
			while start < total
				# minus 1 since starting from 0
				last = [start + (ANDROID_BATCH_LIMIT - 1), total - 1].min
				chunk = registration_ids[start..last]
				response = gcm.send_notification(chunk, options)
				start = last + 1
			end
			
		end

		if not publisher.ios_api_key.empty?
			# code to send notification to ios
		end

  	end

end