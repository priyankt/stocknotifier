class Notification
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true
  property :text, Text, :required => true
  property :schedule_dttm, DateTime, :lazy => true
  property :video1, String
  property :video2, String
  property :video3, String
  mount_uploader :image1, Uploader
  mount_uploader :image2, Uploader
  mount_uploader :image3, Uploader
  mount_uploader :image4, Uploader
  mount_uploader :image5, Uploader
  property :sent, Boolean, :default => true
  property :location, String
  property :android_response, Text
  property :active, Boolean, :default => true
  property :comment_count, Integer, :default => 0
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher
  belongs_to :sponsor, :required => false
  has n, :viewedNotifications
  has n, :comments

end
