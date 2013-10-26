class Category
  	include DataMapper::Resource

	property :id, Serial
	property :name, String, :unique => true, :required => true
	property :subtitle, String
	property :active, Boolean, :default => true

	property :created_at, DateTime, :lazy => true
  	property :updated_at, DateTime, :lazy => true

  	belongs_to :publisher
  
end
