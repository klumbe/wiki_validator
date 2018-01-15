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

		def as_json(options = {})
			hash = {
				full_page_title: @page_name,
				full_template_name: @template_name,
				status: valid?(),
				errors: @errors
			}

			return hash
		end

		def to_json(*options)
			self.as_json(*options).to_json(*options)
		end

	end

end
