class Comment
  include DataMapper::Resource

  property :id, Serial
  property :text, String, :required => true
  property :active, Boolean, :default => true

  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :subscriber
  belongs_to :notification

end
