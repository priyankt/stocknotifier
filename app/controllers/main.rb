require "send_notification"

StockNotifier::App.controllers do

  get :index, :map => '/' do
    redirect url(:login)
  end

  get :login, :map => '/login' do
    render 'main/login'
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
  
  get :forgot_passwd, :map => '/forgot_passwd' do

   render 'main/forgot_passwd'

  end

  post :forgot_passwd, :map => '/forgot_passwd' do
    email = params[:email] if params.has_key?('email')

    if email.present?
      publisher = Publisher.first(:email => email)
      if publisher == nil
        flash.now[:error] = "Invalid email address. Please try again."
      else
        salt = BCrypt::Engine.generate_salt
        new_passwd = SecureRandom.hex(5)
        publisher.passwd = BCrypt::Engine.hash_secret( new_passwd, salt)
        publisher.salt = salt
        if publisher.valid?
          publisher.save
          Resque.enqueue(SendEmail, {:mailer_name => 'notifier', :email_type => 'forgot_passwd', :publisher_id => publisher.id, :new_passwd => new_passwd, :user_type => 'publisher'})
          flash.now[:success] = "An email has been sent with your new password."
        else
          flash.now[:error] = "An error occured while sending new password. Please try again."
        end
      end
    else
      flash.now[:error] = "Please provide email address and try again."
    end

    render 'main/forgot_passwd'

  end

end
