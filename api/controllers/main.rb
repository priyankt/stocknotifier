require "securerandom"
require "bcrypt"

StockNotifier::Api.controllers do
  
  # Login
  post :login, :map => '/login' do
    # get email                                                                                                                                              
    email = params[:email] if params.has_key?("email")
    publisher_id = params[:publisher_id] if params.has_key?("publisher_id")

    # get subscriber for this email & publisher
    subscriber = Subscriber.first(:email => email, :publisher_id => publisher_id)
    if subscriber
      passwd_hash = BCrypt::Engine.hash_secret(params[:passwd], subscriber.salt)
      ret = {:success => 0}
      if subscriber.passwd == passwd_hash
        # assign unique auth key to this user                                                                                                               
        subscriber.api_key = generate_api_key()
        if subscriber.save
          status 200
          ret = {:success => 1, :user_key => subscriber.api_key}
        else
          status 400
        end
      else
        status 401
      end
    else
      status 400
    end
    
    ret.to_json

  end

  put :forgot_passwd, :map => '/forgot_passwd' do

    salt = BCrypt::Engine.generate_salt
    new_passwd = SecureRandom.hex(5)
    @subscriber.passwd = BCrypt::Engine.hash_secret( new_passwd, salt)
    @subscriber.salt = salt

    if @subscriber.valid?
      @subscriber.save
      Resque.enqueue(SendEmail, {:subscriber_id => @subscriber.id, :new_passwd => new_passwd})
      #StockNotifier::App.deliver(:notifier, :forgot_passwd, @subscriber, new_passwd)
      status 201
      ret = {:success => 1}
    else
      ret = {:success => 0, :errors => @subscriber.errors.to_hash}
    end

    ret.to_json

  end

  post :register, :map => '/register' do

    salt = BCrypt::Engine.generate_salt
    api_key = generate_api_key()
    @subscriber = Subscriber.new(
      :name => params[:name],
      :email => params[:email],
      :passwd => BCrypt::Engine.hash_secret( params[:passwd], salt),
      :salt => salt,
      :city => params[:city],
      :occupation => params[:occupation],
      :phone => params[:phone],
      :api_key => api_key
    )

    @subscriber.publisher = Publisher.get(params[:publisher_id])

    if @subscriber.valid?
      @subscriber.save
      ret = {:success => 1, :id => @subscriber.id, :api_key => api_key}
      status 201
    else
      ret = {:success => 0, :errors => @subscriber.errors.to_hash}
      status 400
    end

    ret.to_json
    
  end

end
