module WikiValidator

	class ValidationError

		attr_reader :location, :template_location, :message, :suberrors

		# location = line_number
		# message = explanation of the error
		# suberrors = errors found when examining sub-constraints
		def initialize(location, template_location, message, suberrors = [])
			@location = location
			@template_location = template_location
			@message = message
			@suberrors = suberrors
		end

		def add_suberror(error)
			if error.kind_of?(ValidationError)
				@suberrors << error
			end
		end

		def as_json(options = {})
			hash = {
				location: @location,
				template_location: @template_location,
				message: @message,
				sub_errors: @suberrors,
			}

			return hash
		end

		def to_json(*options)
			self.as_json(*options).to_json(*options)
		end

	end

end
