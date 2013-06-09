require "securerandom"

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
      flash[:notice] = "Access Denied. Please Login."
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
          flash[:notice] = "Invalid email or password. Please try again."
          redirect url(:login)
        end
      else
        flash[:notice] = "Invalid email or password. Please try again."
        redirect url(:login)
      end
    else
      flash[:notice] = "Please provide both email and password."
      redirect url(:login)
    end

  end

  get :logout, :map => '/logout' do
    session["publisher"] = nil
    redirect url(:login)
  end

  get :users, :map => '/users' do

    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @users = Subscriber.all(:publisher_id => @publisher.id, :order => :created_at.desc).paginate(:page => params[:page], :per_page => 5)
    else
      #@users = @publisher.subscribers.all(:name.like => "%#{keyword}%", :order => :created_at.desc).paginate(:page => params[:page])
      @users = Subscriber.all(:publisher_id => @publisher.id, :conditions => ["name like ? OR email like ?", "%#{keyword}%", "%#{keyword}%"], :order => :created_at.desc).paginate(:page => params[:page], :per_page => 5)
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
    @subscriber.passwd = BCrypt::Engine.hash_secret(SecureRandom.hex(10), salt)
    @subscriber.salt = salt
    
    @subscriber.publisher = @publisher

    if @subscriber.valid?
      @subscriber.save
      flash[:notice] = "New user created successfully!"
    end
    
    render 'web/users/new'

  end

  get :notifications, :map => '/notifications' do
    
    keyword = params[:keyword] if params.has_key?("keyword")
    if keyword.nil?
      @notifications = @publisher.notifications.all(:order => :created_at.desc).paginate(:page => params[:page], :per_page => 2)
    else
      @notifications = @publisher.notifications.all(:text.like => "%#{keyword}%", :order => :created_at.desc).paginate(:page => params[:page])
    end

    total = @notifications.total_entries

    render 'web/notifications/list', :locals => {:total => total}

  end

  get :new_notification, :map => '/notifications/new' do
    
    render 'web/notifications/new'

  end

  post :new_notification, :map => '/notifications/new' do
    
    title = params[:title] if params.has_key?("title")
    text = params[:text] if params.has_key?("text")
    dttm = params[:dttm] if params.has_key?("dttm")

    if(title and text)
      notification = Notification.new(:title => title, :text => text)
      if !dttm.nil? and !dttm.blank? and !dttm.empty?
        notification.schedule_dttm = dttm
      end
      notification.publisher = @publisher
      if notification.valid?
        status 200
        notification.save
        ret = {:success => true}
      else
        status 400
        ret = {:success => false, :errors => notification.errors.to_hash}
      end
    end

    ret.to_json

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
      flash[:notice] = "New sponsorer created successfully!"
    end
    
    render 'web/sponsorers/new'

  end


  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  

end
