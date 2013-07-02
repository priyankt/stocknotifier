class Sponsorer
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true
  property :email, String, :format => :email_address, :required => true
  property :phone, String
  property :address, String
  property :website, String, :format => :url
  property :about, Text
  mount_uploader :logo, Uploader
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher

end
