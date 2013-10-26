class Review
	include DataMapper::Resource
	
	property :id, Serial
	property :text, String
	property :active, Boolean, :default => true
	property :created_at, DateTime
	property :updated_at, DateTime

	belongs_to :place
	belongs_to :subscriber
  
end
