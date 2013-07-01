class Subscriber
  include DataMapper::Resource

  property :id, Serial
  property :email, String, :format => :email_address, :required => true
  property :passwd, String, :required => true
  property :salt, String
  property :api_key, String
  property :name, String
  property :registration_token, String
  property :phone, String
  property :occupation, String
  property :city, String
  # phone type values => android = 1, iphone = 2
  property :phone_type, Integer, :default => 1
  property :active, Boolean, :default => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher
  validates_within :phone_type, :set => [1,2]
  # validates_uniqueness_of :email, :scope => :publisher,
  #   :message => "Current email address is already registered"

end
