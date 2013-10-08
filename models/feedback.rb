class Feedback
	include DataMapper::Resource

	property :id, Serial
	property :text, Text

	property :created_at, DateTime, :lazy => true
  	property :updated_at, DateTime, :lazy => true

  	belongs_to :subscriber
  
end
