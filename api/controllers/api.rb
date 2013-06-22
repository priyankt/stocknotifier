require 'bcrypt'
require 'uuidtools'
require 'dm-serializer/to_json'
require 'json'
require "resque"
require "send_email"

StockNotifier::Api.controllers do

# Check auth before every route except login
  before :except => :login do

    if env.has_key?("HTTP_X_AUTH_KEY") and !env["HTTP_X_AUTH_KEY"].nil?
      api_key = env["HTTP_X_AUTH_KEY"]
      @subscriber = Subscriber.first(:api_key => api_key)
      if @subscriber.nil?
        invalid = true
      end     
    else    
      invalid = true
    end     
      
    if(invalid)
      # if invalis request then send 401 not authorized                                                                                                       
      throw(:halt, [401, "Not Authorized"])
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
      ret = {:success => 0, :errors => @subscriber.errors.to_hash}
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
      ret = {:success => 0, :errors => @subscriber.errors.to_hash}
      status 401
    end

    ret.to_json

  end

  get :get_notifications, :map => '/notifications' do

    last_id = params["last_id"] if params.has_key?("last_id")
    publisher = @subscriber.publisher
    notifications = publisher.notifications.all( :id.gt => last_id )
    notifications.to_json

  end

  post :opened_notifications, :map => '/opened/:notification_id' do
    notification_id = params["notification_id"] if params.has_key?("notification_id")
    viewedNotification = viewedNotification.new(
      :notification_id => notification_id,
      :subscriber_id => @subscriber.id
      )
    if viewedNotification.save
      status 201
      ret = {:success => 1}
    else
      status 401
      ret = {:success => 0}
    end
    
    ret.to_json

  end  

end
