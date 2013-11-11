class ViewedPlace
	include DataMapper::Resource

	property :id, Serial
	# location of the subscriber
	property :lat, Float, :index => true
	property :lng, Float, :index => true

	property :created_at, DateTime, :lazy => true
	property :updated_at, DateTime, :lazy => true

	belongs_to :place
	belongs_to :subscriber
  
end
