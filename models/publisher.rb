class Publisher
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :passwd, String, :required => true
  property :salt, String
  property :api_key, String, :unique => true
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
  property :msg_limit, Integer, :default => 1200
  property :users_limit, Integer, :default => 5000
  property :active, Boolean, :default => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :notifications
  has n, :sponsors
  has n, :places
  has n, :categories
  
end
