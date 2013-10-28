# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::Api.helpers do

	def get_place_images(place)

		p = Place.new

		p.id = place[:id]
		p.image1 = place[:image1]
		p.image2 = place[:image2]
		p.image3 = place[:image3]

		images = Array.new()
		if p.image1.url.present?
			images.push({:url => p.image1.url, :main => p.image1.main.url, :thumb => p.image1.thumb.url})
		end
		if p.image2.url.present?
			images.push({:url => p.image2.url, :main => p.image2.main.url, :thumb => p.image2.thumb.url})
		end
		if p.image3.url.present?
			images.push({:url => p.image3.url, :main => p.image3.main.url, :thumb => p.image3.thumb.url})
		end
		
		return images
		
	end

end
