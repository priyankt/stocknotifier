require 'carrierwave/datamapper'

class Upload

  	include DataMapper::Resource

  	property :id, Serial
  	property :created_at, DateTime
	mount_uploader :file, Uploader

end
