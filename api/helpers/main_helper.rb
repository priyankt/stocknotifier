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

    # if not jain site user then follow normal process
    if subscriber.passwd.length > 32
      passwd_from_user = BCrypt::Engine.hash_secret(passwd, subscriber.salt)
      stored_passwd = subscriber.passwd
    else
      # if jain site user then get md5 hash of passwd
      passwd_from_user = Digest::MD5.hexdigest(passwd)
      # stored passwd is in subscriber password
      stored_passwd = subscriber.passwd
    end

    valid = (passwd_from_user == stored_passwd)
    # if passwd is valid & subscriber is for jain site, then update his passwd
    if valid and subscriber.passwd.length <= 32
      subscriber.salt = BCrypt::Engine.generate_salt
      new_passwd = BCrypt::Engine.hash_secret(passwd, subscriber.salt)
      # update passwd for this jain site user
      subscriber.passwd = new_passwd
    end

    return valid

  end

end
