module WikiValidator

	class Validator

		# Validates a page against a template and returns a ValidationStatus
		def self.validate(page_dto, template_dto)

			page_name = page_dto.name
			page_tree = page_dto.ast

			template_name = page_dto.name
			tempate_tree = page_dto.ast
			
			# check constraints
			status = check_constraints(page_name, template_name, page_tree, template_tree)

			return status
		end

		private

			def check_constraints(page_name, template_name, page_tree, template_tree)
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
