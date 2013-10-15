class Comment
  include DataMapper::Resource

  property :id, Serial
  property :text, String, :required => true
  property :active, Boolean, :default => true

  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :subscriber
  belongs_to :notification

  after :save, :update_comment_count

  def update_comment_count

  	self.notification.comment_count += 1
  	self.notification.save

  end
  
end
