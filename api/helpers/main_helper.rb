# Helper methods defined here can be accessed in any controller or view in the application

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
end
