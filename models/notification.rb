class Notification
  include DataMapper::Resource

  property :id, Serial
  property :text, Text
  property :schedule_dttm, DateTime
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher

end
