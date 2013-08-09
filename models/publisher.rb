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
  property :mailing_list, String, :format => :email_address
  property :android_api_key, String
  property :ios_api_key, String
  mount_uploader :logo, Uploader
  property :language1, String, :default => 'hi', :length => 2
  property :language2, String, :length => 2
  property :language3, String, :length => 2
  property :footer_msg, String
  property :active, Boolean, :default => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :notifications
  
end
