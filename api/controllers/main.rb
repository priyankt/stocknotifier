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
    ret = {:success => 0}
    if subscriber.present?
      if valid_user(subscriber, params[:passwd])
        # assign unique auth key to this user                                                                                                               
        subscriber.api_key = generate_api_key()
        if subscriber.save
          ret = {:success => 1, :api_key => subscriber.api_key}
          status 200
        else
          ret = {:success => 0, :registered_user => 1, :errors => get_formatted_errors(subscriber.errors)}
          status 400
        end
      else
        ret = {:success => 0, :registered_user => 1, :errors => ['Invalid password']}
        status 401
      end
    else
      ret = {:success => 0, :registered_user => 0, :errors => ['Invalid subscriber']}
      status 400
    end
    
    ret.to_json

  end

  put :forgot_passwd, :map => '/forgot_passwd' do

    subscriber = Subscriber.first(:email => params[:email], :publisher_id => params[:publisher_id])
    if subscriber
      salt = BCrypt::Engine.generate_salt
      new_passwd = SecureRandom.hex(2)
      subscriber.passwd = BCrypt::Engine.hash_secret( new_passwd, salt)
      subscriber.salt = salt

      if subscriber.valid?
        subscriber.save
        Resque.enqueue(SendEmail, {
          :mailer_name => 'notifier',
          :email_type => 'forgot_passwd_subscriber',
          :subscriber_id => subscriber.id,
          :new_passwd => new_passwd
        })
        status 200
        ret = {:success => 1}
      else
        status 400
        ret = {:success => 0, :errors => get_formatted_errors(subscriber.errors)}
      end
    else
      status 400
      ret = {:success => 0, :errors => ["Invalid email: #{params[:email]}"]}
    end

    ret.to_json

  end

  post :register, :map => '/register' do

    salt = BCrypt::Engine.generate_salt
    api_key = generate_api_key()
    subscriber = Subscriber.new(
      :name => params[:name],
      :email => params[:email],
      :passwd => BCrypt::Engine.hash_secret( params[:passwd], salt),
      :salt => salt,
      :city => params[:city],
      :occupation => params[:occupation],
      :phone => params[:phone],
      :api_key => api_key
    )

    subscriber.publisher = Publisher.get(params[:publisher_id])

    if subscriber.valid?
      begin
        subscriber.save
        ret = {:success => 1, :id => subscriber.id, :api_key => api_key}
        status 201
      rescue DataObjects::IntegrityError => e
        ret = {:success => 0, :errors => ["Email #{subscriber.email} is already registered."]}
        status 400
      end
      
    else
      
      ret = {:success => 0, :errors => get_formatted_errors(subscriber.errors)}
      status 400
    end

    ret.to_json
    
  end

end
