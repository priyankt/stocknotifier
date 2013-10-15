require 'digest/md5'

StockNotifier::Api.helpers do

	def generate_api_key
		SecureRandom.hex(15)
	end
  
	def get_formatted_errors(errors)

		err_list = Array.new()
  	errors.each do |e|
  		err_list.push(e.pop)
  	end

  	return err_list

	end

  def valid_user(subscriber, passwd)

    passwd_from_user = BCrypt::Engine.hash_secret(passwd, subscriber.salt)
    
    return passwd_from_user == subscriber.passwd

  end

end
