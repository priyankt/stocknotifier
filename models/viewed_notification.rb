class ViewedNotification
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :notification, :key => true
  belongs_to :subscriber, :key => true

end
