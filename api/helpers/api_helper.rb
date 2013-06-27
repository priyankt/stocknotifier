# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::Api.helpers do

	def get_display_image(n)

		no_image = '/images/display_image.png'

		return n.image1.thumb.url || n.image2.thumb.url || n.image3.thumb.url || n.image4.thumb.url || n.image5.thumb.url || no_image

	end

	def get_video_thumb(video_id)

		"img.youtube.com/vi/#{video_id}/0.jpg"

	end

	def get_images(n)

		images = Array.new()
		if n.image1.url
			images.push({:url => n.image1.url, :main => n.image1.main.url, :thumb => n.image1.thumb.url})
		end
		if n.image2.url
			images.push({:url => n.image2.url, :main => n.image2.main.url, :thumb => n.image2.thumb.url})
		end
		if n.image3.url
			images.push({:url => n.image3.url, :main => n.image3.main.url, :thumb => n.image3.thumb.url})
		end
		if n.image4.url
			images.push({:url => n.image4.url, :main => n.image4.main.url, :thumb => n.image4.thumb.url})
		end
		if n.image5.url
			images.push({:url => n.image5.url, :main => n.image5.main.url, :thumb => n.image5.thumb.url})
		end

		return images
		
	end

	def get_videos(n)

		videos = Array.new()
      	if n.video1.present?
        	videos.push({:id => n.video1, :thumb => get_video_thumb(n.video1)})
      	end

      	return videos

	end

end
