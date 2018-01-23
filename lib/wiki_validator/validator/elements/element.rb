require 'json'
require 'securerandom'
require_relative '../validation/validation_item.rb'
require_relative '../validation/validation_error.rb'

module WikiValidator

  class Element

    # raw string of input (not splitted)
    # all parts of the (splitted) string that form the element
    attr_reader :id, :raw, :type, :subtype, :content_raw, :content, :children
  	attr_accessor :line_number

    # make class-level instance variable readable
    class << self; attr_reader :regex, :starts_with end

    @regex = //
    @starts_with = //


  	def self.matches?(s)
  		if !s.nil? && s.instance_of?(String) && @regex.match(s)
  			return true
  		else
  			return false
  		end
  	end

    def initialize(raw, params={})
  		# generate a uuid if no id is provided
  		@id = params.fetch(:id, SecureRandom.uuid)
      @raw = raw
      @type = params.fetch(:type, :undefined).downcase.to_sym
  		@subtype = params.fetch(:subtype, :undefined).downcase.to_sym
      @line_number = params.fetch(:line_number, -1)
      @content_raw = params.fetch(:content_raw, "")
  		@children = params.fetch(:children, [])
      rectify_params()
      init(params)
    end

  	def set_id(id)
  		@id = id
  	end

    def is_direct_successor?(element)
  		successor = false
  		if self.parent_id() == element.parent_id()
  			id = @id.split('_').map(&:to_i)
  			el_id = element.id.split('_').map(&:to_i)

  			if id.size  == el_id.size
  				if ((id.last + 1) == el_id.last)
  					successor = true
  				end
  			end
  		end

  		return successor
  	end

  	def parent_id
  		parent_id = ''
  		if match_id?(@id)
  			pos = @id.rindex('_')
  			if !pos.nil?
  				pos = @id.rindex('_') - 1
  				parent_id = @id[0..pos]
  			end
  		end

  		return parent_id
  	end

  	# returns:
  	# -2 if self.id or element.id not set properly
  	# -1 if self.id < element.id
  	#  0 if self.id == element.id
  	#  1 if self.id > element.id
  	def compare_id(element)
  		result = 0

  		if match_id?(@id) && match_id?(element.id)
  			id = @id.split('_').map(&:to_i)
  			el_id = element.id.split('_').map(&:to_i)

  			if id.size <= el_id.size
  				id_a = id
  				id_b = el_id
  			else
  				id_a = el_id
  				id_b = id
  			end

  			id_a.each_with_index do |num, i|
  				if num < id_b[i]
  					result = -1
  					break
  				elsif num > id_b[i]
  					result = 1
  					break
  				end
  			end

  			# case where element is child of self (or vice versa)
  			if result == 0 && id.size != el_id.size
  				result = -1
  			end

  			if (id.size > el_id.size && result != 0)
  				# negate results
  				result = - result
  			end

  		else
  			result = -2
  		end

  		return result
  	end

  	# add children (everything that is within a section or template-item)
  	def add_child(child_element)
  		if !child_element.nil? && child_element.kind_of?(Element)
  			@children << child_element
  		end
  	end

    def add_content_raw(content_lines)
  		if !content_lines.nil? && content_lines.instance_of?(String)
      	@content_raw += content_lines
  		end
    end

    def parse_content_raw(content_parser)
      @children = content_parser.parse(@content_raw)
      @children.each do |element|
        element.parse_content_raw(content_parser)
      end

  		return @children
    end

  	# can be overwritten to allow specific validation
  	def validate(elements)
  		validation_item = ValidationItem.new(self)

  		if elements.instance_of?(Array)
  			elements.each do |element|
  				if equals?(element)
  					validation_item.add_valid_element(element)
  				end
  			end
  		end

  		if validation_item.valid_elements.empty?
        if !@subtype.nil? && @subtype != :undefined
          msg_sub = " and subtype #{@subtype.upcase}"
        end
  			msg = "No #{@type.upcase}#{msg_sub} found.)"
  			error = ValidationError.new(-1, @line_number, msg)
  			validation_item.add_error(error)
  		end

  		return validation_item
  	end

  	# should be overwritten to allow specific comparison to element
  	def equals?(element)
  		equal = false

  		if element.kind_of?(Element) && @type == element.type
  			if Constants::ADDITIONAL_KEYWORDS.include?(@type)
  				if @raw == element.raw
  					equal = true
  				end
  			elsif @content_raw.strip == element.content_raw.strip
  				equal = true
  			end
  		end
  		return equal
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

    def to_markup
      # if it is no TemplateItem, the following fits:
      return @raw
    end

    private

      def rectify_params
        if @line_number.instance_of?(String)
          if @line_number.strip.match(/\A[-+]\d+\z/)
            @line_number = @line_number.to_i
          else
            @line_number = -1
          end
        end

        if !@children.instance_of?(Array)
          @children = []
        end
      end

      # should be overwritten in subclasses instead of the constructor
      def init(params)
      end

  		def match_id?(id)
  			return id.match(/\A(\d+)(_\d+)*$/)
  		end

  end

end
