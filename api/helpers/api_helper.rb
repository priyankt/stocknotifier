# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::Api.helpers do

	def get_display_image

		'/images/display_image.png'
		
	end

	def get_video_thumb(video_id)

		"img.youtube.com/vi/#{video_id}/0.jpg"

	end
end
