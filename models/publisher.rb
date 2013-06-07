class Publisher
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :passwd, String, :required => true
  property :salt, String
  property :api_key, String
  property :name, String
  property :address, Text
  property :phone, String
  property :website, String, :format => :url
  property :desc, Text
  property :occupation, String
  property :city, String
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :notifications
  
end
