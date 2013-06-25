class SendNotification

	ANDROID_BATCH_LIMIT = 1000

	@queue = :send_notification

	def self.perform(notification_id)

    	notification = Notification.get(notification_id)
    	publisher = notification.publisher

    	# send android notifications
    	registration_ids = Subscriber.all(
    		:fields => [:registration_token],
    		:publisher_id => publisher.id,
    		:active => true,
    		:registration_token.not => nil
    		)

    	unless publisher.android_api_key.nil?
	    	
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

		unless publisher.ios_api_key.nil?
			# code to send notification to ios
		end

		notification.sent = true
		if notification.valid?
			notification.save
		else
			# print some error here
		end

  	end

end