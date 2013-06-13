class Notification
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :text, Text
  property :schedule_dttm, DateTime, :lazy => true
  mount_uploader :image, Uploader
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher
  has n, :viewedNotifications

end
