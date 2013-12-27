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
  mount_uploader :profile_pic, Uploader
  property :active, Boolean, :default => true
  property :lat, Float, :index => true
  property :lng, Float, :index => true
  #property :can_comment, :default => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  has n, :notifications
  has n, :places
  has n, :comments

  belongs_to :publisher
  validates_within :phone_type, :set => [1,2]
  # validates_uniqueness_of :email, :scope => :publisher,
  #   :message => "Current email address is already registered"

  def format_for_app

    return {
      :id => self.id,
      :email => self.email,
      :name => self.name,
      :phone => self.phone,
      :occupation => self.occupation,
      :city => self.city,
      :image => (self.profile_pic.present? ? {:thumb => self.profile_pic.thumb.url, :main => self.profile_pic.main.url, :url => self.profile_pic.url} : nil)
    }

  end

end
