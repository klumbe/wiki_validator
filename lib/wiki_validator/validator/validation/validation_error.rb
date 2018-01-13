module WikiValidator
	
	class ValidationError

		attr_reader :location, :message, :suberrors

		# location = line_number
		# message = explanation of the error
		# suberrors = errors found when examining sub-constraints
		def initialize(location, message, suberrors = [])
			@location = location
			@message = message
			@suberrors = suberrors
		end

		def add_suberror(error)
			if error.kind_of?(ValidationError)
				@suberrors << error
			end
		end
	end

end
