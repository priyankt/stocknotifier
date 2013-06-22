# Helper methods defined here can be accessed in any controller or view in the application

StockNotifier::Api.helpers do

	def generate_api_key
		SecureRandom.hex(15)
	end
  
end
