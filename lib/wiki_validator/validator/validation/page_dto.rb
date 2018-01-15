module WikiValidator

	class PageDTO

		attr_accessor :ast, :raw_content
		attr_reader :name, :namespace

		def initialize(name, namespace, raw_content)
			@name = name
			@namespace = namespace
			@raw_content = raw_content
			# abstract syntax tree of the raw_content
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

		def full_title
			return "#{@namespace}:#{@name}"
		end

		def as_json(options={})
			return self.attributes
		end

		def to_json(*options)
			return self.as_json(*options).to_json(*options)
		end

	end

end
