module WikiValidator

	class ValidationStatus

		attr_reader :page_name, :template_name, :errors

		def initialize(page_full_title, template_full_title)
			@page_name = page_full_title
			@template_name = template_full_title
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
