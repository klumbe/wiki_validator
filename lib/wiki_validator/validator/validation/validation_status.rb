module WikiValidator

	class ValidationStatus

		attr_reader :page_name, :template_name, :errors

		def initialize(page_name, template_name)
			@page_name = page_name
			@template_name = template_name
			@errors = []
		end

		# adds ValidationError to errors-list
		def add_error(error)
			@errors << error
		end

		def add_errors(errors)
			@errors.concat(errors)
		end

		def valid?
			return @errors.empty?
		end
	end

end
