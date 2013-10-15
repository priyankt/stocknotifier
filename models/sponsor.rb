class Sponsor
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :description, String
  mount_uploader :banner, Uploader, :required => true
  mount_uploader :large, Uploader
  property :website, String, :format => :url
  property :active, Boolean, :default => true
  property :created_at, DateTime, :lazy => true
  property :updated_at, DateTime, :lazy => true

  belongs_to :publisher

  def format_for_app
    return {
      :small_image => self.banner.url,
      :large_image => (self.large.url.blank? ? nil : self.large.url),
      :action_url => (self.website.blank? ? nil : self.website)
    }
  end

end
