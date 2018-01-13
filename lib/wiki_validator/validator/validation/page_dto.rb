module WikiValidator

	class PageDTO

		attr_accessor :ast, :content_string
		attr_reader :name, :namespace

		def initialize(name, namespace, content_string)
			@name = name
			@namespace = namespace
			@content_string = content_string
			# abstract syntax tree of the content_string
			@ast = []
		end

		def attributes
			values = {}

			[self].each do |obj|
			# get class instance variables and instance variables
				obj.instance_variables.each do |var|
					# fill the hash with the variables
					values[var.to_s.delete("@").to_sym] = obj.instance_variable_get(var)
				end
			end

			values
		end

		def as_json(options={})
			return self.attributes
		end

		def to_json(*options)
			return self.as_json(*options).to_json(*options)
		end

	end

end
