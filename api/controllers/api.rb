require 'dm-serializer/to_json'
require 'json'
require "resque"
require "send_email"

StockNotifier::Api.controllers do

# Check auth before every route except login
  before do

    @subscriber = get_subscriber_from_key()
    if @subscriber.blank?
      # if invalis request then send 401 not authorized
      halt 401, {:success => 0, :errors => ['Authentication failed. Please logout and login again.']}.to_json
    end

  end

  # Logout
  get :logout, :map => '/logout' do

    @subscriber.registration_token = nil
    @subscriber.api_key = nil
    if @subscriber.save
      status 200
      ret = {:success => 1}
    else
      status 401
      ret = {:success => 0, :errors => get_formatted_errors(@subscriber.errors)}
    end

    ret.to_json

  end

  get :about, :map => '/about' do

    pub = @subscriber.publisher
    ret = {
      :name => pub.name,
      :address => pub.address,
      :phone => pub.phone,
      :website => pub.website,
      :email => pub.email,
      :desc => pub.desc
    }
    
    ret.to_json

  end

  post :registration_token, :map => '/registration_token' do

    token = params[:token] if params.has_key?("token")
    @subscriber.registration_token = token
    if @subscriber.save
      status 200
      ret = {:success => 1}
    else
      ret = {:success => 0, :errors => get_formatted_errors(@subscriber.errors)}
      status 401
    end

    ret.to_json

  end

  get :get_notifications, :map => '/notifications' do

    last_updated_at = DateTime.parse(params["last_updated_at"]) if params.has_key?("last_updated_at")
    
    publisher = @subscriber.publisher
    fields = [:id, :title, :text, :video1, :image1, :image2, :image3, :sent_dttm]
    if last_updated_at
      # TODO: Find a better way to specify timezone
      last_updated_at = last_updated_at.change(:offset => "+0530")
      notifications = publisher.notifications.all( :fields => fields, :sent_dttm.gt => last_updated_at, :order => :sent_dttm.desc, :sent => true, :limit => 20, :active => true )
    else
      notifications = publisher.notifications.all( :fields => fields, :order => :sent_dttm.desc, :sent => true, :limit => 20, :active => true )
    end

    data = Array.new()
    notifications.each do |n|

      display_image = get_display_image(n)
      
      data.push({
        :id => n.id,
        :title => n.title,
        :text => n.text,
        :videos => get_videos(n),
        :images => get_images(n),
        :display_image => display_image, # stub image when no image is uploaded with message
        :updated_at => n.sent_dttm,
        :comment_count => 0,
        :sponsor => (n.sponsor.blank? ? nil : n.sponsor.format_for_app),
        :subscriber => (n.subscriber.blank? ? nil : n.subscriber.format_for_app)
      })

    end
    
    data.to_json

  end

  post :opened_notifications, :map => '/opened/:notification_id' do
    notification_id = params[:notification_id] if params.has_key?(:notification_id)
    viewedNotification = ViewedNotification.new(
      :notification_id => notification_id,
      :subscriber_id => @subscriber.id
      )
    if viewedNotification.valid?
      viewedNotification.save
      status 201
      ret = {:success => 1}
    else
      status 400
      ret = {:success => 0, :errors => get_formatted_errors(viewedNotification.errors)}
    end
    
    ret.to_json

  end

  post :change_passwd, :map => '/change_passwd' do

    current = params[:current_passwd] if params.has_key?("current_passwd")
    new_passwd = params[:new_passwd] if params.has_key?("new_passwd")
    new_passwd_repeat = params[:new_passwd_repeat] if params.has_key?("new_passwd_repeat")

    if current and new_passwd and new_passwd_repeat
      if new_passwd != new_passwd_repeat
        status 400
        ret = {:success => 0, :errors => ['New password and repeat password should match.']}
      else
        passwd_hash = BCrypt::Engine.hash_secret(current, @subscriber.salt)
        if passwd_hash == @subscriber.passwd
          salt = BCrypt::Engine.generate_salt
          @subscriber.passwd = BCrypt::Engine.hash_secret( new_passwd, salt)
          @subscriber.salt = salt
          if @subscriber.valid?
            @subscriber.save
            status 200
            ret = {:success => 1}
          else
            status 400
            ret = {:success => 0, :errors => get_formatted_errors(@subscriber.errors)}
          end
        else
          status 400
          ret = {:success => 0, :errors => ['Invalid current password.']}
        end
      end
    else
      status 400
      ret = {:success => 0, :errors => ['Please provide all the values required to change password.']}
    end

    ret.to_json

  end

  get :profile, :map => '/profile' do

    @subscriber.format_for_app.to_json

  end

  put :profile, :map => '/profile' do

    @subscriber.email = params[:email] if params.has_key?('email')
    @subscriber.name = params[:name] if params.has_key?('name')
    @subscriber.phone = params[:phone] if params.has_key?('phone')
    @subscriber.occupation = params[:occupation] if params.has_key?('occupation')
    @subscriber.city = params[:city] if params.has_key?('city')
    @subscriber.profile_pic = params[:profile_pic] if params.has_key?('profile_pic')
    
    if @subscriber.valid?
      @subscriber.save
      status 200
      ret = {:success => 1, :subscriber_id => @subscriber.id}
    else
      status 400
      ret = {:success => 0, :errors => get_formatted_errors(@subscriber.errors)}
    end

    ret.to_json
    
  end

  get :user_count, :map => '/subscribers/count' do

    count = Subscriber.count(:publisher_id => @subscriber.publisher.id)
    ret = {:count => count}

    status 200
    
    ret.to_json

  end

  post :feedback, :map => '/feedback' do

    feedback = Feedback.new
    feedback.text = params[:text] if params.has_key?('text')

    feedback.subscriber = @subscriber

    if feedback.valid?
      feedback.save
      if feedback.text.length > 20
        Resque.enqueue(SendEmail, {
            :mailer_name => 'notifier',
            :email_type => 'feedback',
            :subscriber_id => @subscriber.id,
            :msg => feedback.text
        })
      end
      status 200
      ret = {:success => 1, :feedback_id => feedback.id}
    else
      status 400
      ret = {:success => 0, :errors => get_formatted_errors(@subscriber.errors)}
    end
    
    ret.to_json

  end

  # Get comments for notification
  get :comments, :map => '/notification/:id/comments' do

    comments = Comment.all(:notification_id => params[:id], :active => true, :order => [:created_at.desc])
    status 200

    ret = []
    comments.each do |c|

      ret.push({
        :text => c.text,
        :subscriber_id => c.subscriber.id,
        :name => c.subscriber.name,
        :dttm => c.created_at,
        :image => (c.subscriber.profile_pic ? {:thumb => c.subscriber.profile_pic.thumb.url, :main => c.subscriber.profile_pic.main.url, :url => c.subscriber.profile_pic.url} : nil)
      })

    end

    ret.to_json

  end

  # Get comments for notification
  get :comment_count, :map => '/notification/:id/comment/count' do

    n = Notification.get(params[:id])
    
    if n.present?
      ret = {:success => 1, :count => n.comments.all(:active => true).count}
    else
      ret = {:success => 0, :errors => ['Invalid message. Please try again.']}
    end

    return ret.to_json

  end

  # Add comment for particluar notification
  post :comment, :map => '/notification/:id/comment' do

    #if @subscriber.can_comment
    
      comment = Comment.new(:text => params[:text], :notification_id => params[:id], :subscriber_id => @subscriber.id)
      if comment.valid?
        comment.save
        status 200
        ret = {:success => 1, :comment_id => comment.id}
      else
        status 400
        ret = {:success => 0, :errors => get_formatted_errors(comment.errors)}
      end

    #else

      #status 400
      #ret = {:success => 0, :errors => ['You are not allowed to comment. Please contact admin.']}

    #end

    ret.to_json

  end

  get :display_profile, :map => '/user/:id/profile' do

    user = Subscriber.get(params[:id])
    if user.present?
      ret = user.format_for_app
      ret[:comments_count] = user.comments.count
      ret[:news_count] = user.notifications.count
      ret[:places_count] = user.places.count
    else
      ret = {:success => 0, :errors => ['Error: User does not exists.']}
    end

    return ret.to_json

  end

end
