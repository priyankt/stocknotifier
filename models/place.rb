class Place
  	include DataMapper::Resource

	property :id, Serial
	property :name, String, :required => true, :unique => true
	property :description, Text
	property :phone, String
	property :address, String
	mount_uploader :image1, Uploader
	mount_uploader :image2, Uploader
	mount_uploader :image3, Uploader
	property :lat, Float, :index => true
	property :lng, Float, :index => true
	property :verified, Boolean, :default => false

	property :created_at, DateTime, :lazy => true
  	property :updated_at, DateTime, :lazy => true

  	belongs_to :subscriber
  	belongs_to :publisher

  	has n, :categories, :through => Resource
  	has n, :reviews
  
end
