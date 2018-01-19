$LOAD_PATH << File.dirname(__FILE__)

Dir[File.expand_path("elements/*.rb", File.dirname(__FILE__))].each do |file|
  require file
end

require 'wiki_validator/validator/validation/validation_status'
require 'wiki_validator/validator/validation/page_dto'

module WikiValidator

	class Validator

		# Validates a page against a template and returns a ValidationStatus
		def self.validate(page_dto, template_dto)

			page_name = page_dto.full_title
			page_tree = page_dto.content

			template_name = template_dto.full_title
			template_tree = template_dto.content

			# check constraints
			status = check_constraints(page_name, template_name, page_tree, template_tree)

			return status
		end

		private

			def self.check_constraints(page_name, template_name, page_tree, template_tree)
				status = ValidationStatus.new(page_name, template_name)
				template_tree.each do |item|
					validation_item = item.validate(page_tree)
					if !validation_item.valid?
						status.add_errors(validation_item.errors)
					end
				end

				return status
			end
	end

end
