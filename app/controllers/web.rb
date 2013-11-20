require "securerandom"
require "resque"
require "send_notification"

StockNotifier::App.controllers do
  
  # Check auth before every route except login
  before do
    
    @publisher = get_publisher_from_session()
    if @publisher.blank?
      # if invalis request then send 401 not authorized                                                                                                       
      flash[:error] = "Access Denied. Please Login."
      redirect url(:login)
    end

  end

  get :dashboard, :map => '/dashboard' do

    render 'web/users/dashboard'

  end

  get :logout, :map => '/logout' do
    session["publisher"] = nil
    flash[:success] = "You have logged out successfully."
    redirect url(:login)
  end

  get :users, :map => '/users' do

    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @users = Subscriber.all(:publisher_id => @publisher.id, :order => :created_at.desc).paginate(:page => params[:page])
    else
      @users = Subscriber.all(:publisher_id => @publisher.id, :conditions => ["name like ? OR email like ? OR city like ?", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
    end

    total = @users.total_entries

    render 'web/users/list', :locals => {:total => total}

  end

  get :new_user, :map => '/users/new' do
    
    @subscriber = Subscriber.new()

    render 'web/users/new'

  end

  post :new_user, :map => '/users/new' do

    @subscriber = Subscriber.new(params[:subscriber])
    
    salt = BCrypt::Engine.generate_salt
    user_passwd = SecureRandom.hex(5)
    @subscriber.passwd = BCrypt::Engine.hash_secret( user_passwd, salt)
    @subscriber.salt = salt
    
    @subscriber.publisher = @publisher

    if @subscriber.valid?
      @subscriber.save
      Resque.enqueue(SendEmail, {:mailer_name => 'notifier', :email_type => 'new_user', :subscriber_id => @subscriber.id, :new_passwd => user_passwd})
      flash[:success] = "User #{@subscriber.name} created successfully."
      redirect url(:new_user)
    else
      flash.now[:error] = "Failed to create user #{@subscriber.name}."
      render 'web/users/new'
    end
    
  end

  get :manage_user, :map => '/users/manage/:id' do

    subscriber = Subscriber.get(params[:id])
    subscriber.active = params[:active]

    if subscriber.valid?
      subscriber.save
    end
    
    redirect(:users)

  end

  get :notifications, :map => '/notifications' do
    
    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @notifications = @publisher.notifications.all(:order => :sent_dttm.desc).paginate(:page => params[:page])
    else
      @notifications = @publisher.notifications.all(:conditions => ["title like ? OR text like ?", "%#{keyword}%", "%#{keyword}%"], :order => :sent_dttm.desc).paginate(:page => params[:page])
    end

    total = @notifications.total_entries

    render 'web/notifications/list', :locals => {:total => total}

  end

  get :notification_details, :map => '/notifications/details/:id' do
    
    notification = @publisher.notifications.get(params[:id])
    
    render 'web/notifications/details', :locals => {:notification => notification}

  end

  get :new_notification, :map => '/notifications/new' do

    @notification  = Notification.new()
    
    # params = {
    #   :title => 'Test Video',
    #   :description => 'Test Description',
    #   :category => 'People',
    #   :keywords => ['community']
    # }

    # videos_url = url(:new_notification)

    # client = YouTubeIt::Client.new(
    #   :username => "priyankgt",
    #   :password =>  "b1uebott!e",
    #   :dev_key => "AI39si6qE58xznZSd7J7IRSQCni3uEP6TuhaQmU89dXiu8DPF8VWQ0YFZGsXXe_rEFSQUZsGLxb9V_cqXoT_PMW9lC4qibb9lQ"
    # )

    # @upload_info = client.upload_token(params, videos_url)
    # puts @upload_info
    
    render 'web/notifications/new'

  end

  post :new_notification, :map => '/notifications/new' do

    if params[:notification][:sponsor_id].blank?
      params[:notification].delete('sponsor_id')
    end

    @notification = Notification.new(params[:notification])

    if params[:notification][:schedule_dttm].blank?
      @notification.schedule_dttm = nil
    else
      # change timezone to IST
      @notification.schedule_dttm = @notification.schedule_dttm.change(:offset => "+0530")
      @notification.sent = false
    end

    @notification.publisher = @publisher

    if @publisher.notifications.count <= @publisher.msg_limit
      if @notification.valid?
        @notification.save
        if @notification.schedule_dttm.nil?
          Resque.enqueue(SendNotification, @notification.id)
          flash[:success] = "Message sent successfully."
        else
          Resque.enqueue_at(@notification.schedule_dttm, SendNotification, @notification.id)
          flash[:later] = "Your message will be sent on " + format_date(@notification.schedule_dttm)
        end

        redirect url(:notifications)
      else
        flash.now[:error] = "Error while sending message. Try again."
        render 'web/notifications/new'
      end
    else
      flash.now[:error] = "Limit exceeded. Please contact notifyme team."
      render 'web/notifications/new'
    end
  
  end

  get :sponsors, :map => '/sponsors' do

    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @sponsors = Sponsor.all(:publisher_id => @publisher.id, :order => :created_at.desc).paginate(:page => params[:page])
    else
      @sponsors = Sponsor.all(:publisher_id => @publisher.id, :conditions => ["name like ?", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
    end

    total = @sponsors.total_entries

    render 'web/sponsors/list', :locals => {:total => total}

  end

  get :new_sponsor, :map => '/sponsors/new' do
    
    @sponsor = Sponsor.new()

    render 'web/sponsors/new'

  end

  post :new_sponsor, :map => '/sponsors/new' do

    @sponsor = Sponsor.new(params[:sponsor])
    @sponsor.publisher = @publisher

    if @sponsor.valid?
      @sponsor.save
      flash[:success] = "Sponsor #{@sponsor.name} created successfully."
      redirect url(:new_sponsor)
    else
      flash.now[:error] = "Failed to create sponsor #{@sponsor.name}."
      render 'web/sponsors/new'
    end
    
    render 'web/sponsors/new'

  end

  get :manage_sponsor, :map => '/sponsor/manage/:id/' do

    sponsor = Sponsor.get(params[:id])
    sponsor.active = params[:active]

    if sponsor.valid?
      sponsor.save
    end
    
    redirect(:sponsors)

  end

  get :change_passwd, :map => '/change_passwd' do
    
    render 'web/change_passwd'

  end

  post :change_passwd, :map => '/change_passwd' do

    current = params[:current_passwd] if params.has_key?("current_passwd")
    new_passwd = params[:new_passwd] if params.has_key?("new_passwd")
    new_passwd_repeat = params[:new_passwd_repeat] if params.has_key?("new_passwd_repeat")

    if current and new_passwd and new_passwd_repeat
      if new_passwd != new_passwd_repeat
        flash.now[:error] = "New password and repeat password should match."
      else
        passwd_hash = BCrypt::Engine.hash_secret(current, @publisher.salt)
        if passwd_hash == @publisher.passwd
          salt = BCrypt::Engine.generate_salt
          @publisher.passwd = BCrypt::Engine.hash_secret( new_passwd, salt)
          @publisher.salt = salt
          if @publisher.valid?
            @publisher.save
            flash[:success] = "Password changed successfully."
            redirect url(:change_passwd)
          else
            flash.now[:error] = "Something went wrong. Please try again."
          end
        else
          flash.now[:error] = "Invalid current password."
        end
      end
    else
      flash.now[:error] = "Please provide all the values and try again."
    end

    render 'web/change_passwd'

  end

  get :delete_comment, :map => '/comment/:id' do

    comment = Comment.get(params[:id])
    if comment.present?
      comment.active = false
      if comment.valid?
        comment.save
      end
    end

    redirect(url(:notification_details, :id => comment.notification_id))

  end

end
