require "securerandom"
require "resque"
require "send_notification"

StockNotifier::App.controllers do
  
  # Check auth before every route except login
  before :except => :login do
    if logged_in?
      publisher_id = session[:publisher]
      @publisher = Publisher.get(publisher_id)
      if @publisher.nil?
        invalid = true
      end     
    else    
      invalid = true
    end     
      
    if(invalid)
      # if invalis request then send 401 not authorized                                                                                                       
      flash[:error] = "Access Denied. Please Login."
      redirect url(:login)
    end

  end

  get :index, :map => '/' do
    redirect url(:login)
  end

  get :login, :map => '/login' do
    render 'web/login'
  end

  post :login, :map => '/login' do
    email = params[:email] if params.has_key?("email")
    passwd = params[:passwd] if params.has_key?("passwd")

    if email and passwd
      publisher = Publisher.first(:email => email)
      if publisher
        passwd_hash = BCrypt::Engine.hash_secret(passwd, publisher.salt)
        if publisher.passwd == passwd_hash
          session[:publisher] = publisher.id
          redirect url(:new_notification)
        else
          flash[:error] = "Invalid email or password. Please try again."
          redirect url(:login)
        end
      else
        flash[:error] = "Invalid email or password. Please try again."
        redirect url(:login)
      end
    else
      flash[:error] = "Please provide both email and password."
      redirect url(:login)
    end

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
      #@users = @publisher.subscribers.all(:name.like => "%#{keyword}%", :order => :created_at.desc).paginate(:page => params[:page])
      @users = Subscriber.all(:publisher_id => @publisher.id, :conditions => ["name like ? OR email like ?", "%#{keyword}%", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
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
      # if params[:active]
      #   flash[:notice] = "#{subscriber.name} activated successfully"
      # else
      #   flash[:notice] = "#{subscriber.name} deactivated successfully"
      # end
    end
    
    redirect(:users)

  end

  get :notifications, :map => '/notifications' do
    
    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @notifications = @publisher.notifications.all(:order => :created_at.desc).paginate(:page => params[:page])
    else
      @notifications = @publisher.notifications.all(:conditions => ["title like ? OR text like ?", "%#{keyword}%", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
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
    
    render 'web/notifications/new'

  end

  post :new_notification, :map => '/notifications/new' do

    @notification = Notification.new(params[:notification])
    if params[:notification][:schedule_dttm].nil? or params[:notification][:schedule_dttm].blank? or params[:notification][:schedule_dttm].empty?
      @notification.schedule_dttm = nil
    end
    @notification.publisher = @publisher
    if @notification.valid?
      @notification.save
      Resque.enqueue(SendNotification, @notification.id)
      flash[:success] = "Message sent successfully."
      redirect url(:new_notification)
    else
      puts @notification.errors.to_hash
      flash.now[:error] = "Error while sending message. Try again."
      render 'web/notifications/new'
    end
  
  end

  get :sponsorers, :map => '/sponsorers' do

    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @sponsorers = Sponsorer.all(:publisher_id => @publisher.id, :order => :created_at.desc).paginate(:page => params[:page])
    else
      @sponsorers = Sponsorer.all(:publisher_id => @publisher.id, :conditions => ["name like ? OR email like ?", "%#{keyword}%", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page])
    end

    total = @sponsorers.total_entries

    render 'web/sponsorers/list', :locals => {:total => total}

  end

  get :new_sponsorer, :map => '/sponsorers/new' do
    
    @sponsorer = Sponsorer.new()

    render 'web/sponsorers/new'

  end

  post :new_sponsorer, :map => '/sponsorers/new' do

    @sponsorer = Sponsorer.new(params[:sponsorer])
    @sponsorer.publisher = @publisher

    if @sponsorer.valid?
      @sponsorer.save
      flash[:success] = "Sponsorer #{@sponsorer.name} created successfully."
      redirect url(:new_sponsorer)
    else
      flash.now[:error] = "Failed to create sponsorer #{@sponsorer.name}."
      render 'web/sponsorers/new'
    end
    
    render 'web/sponsorers/new'

  end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

end
