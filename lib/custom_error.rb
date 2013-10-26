class CustomError < StandardError

	attr :errors

	def initialize(errors)
    	@errors = errors
  	end

end