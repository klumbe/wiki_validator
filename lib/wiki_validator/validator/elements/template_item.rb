$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'
require_relative '../helper'

module WikiValidator

  class TemplateItem < Element

    attr_reader :min, :max, :attribs

    # attributes not used for comparing elements
    SPECIAL_ATTRIBUTES = [:min, :max, :amount, :strict]

    @re_type = /((?<type>[a-z]+)(_(?<subtype>([a-z]+)))?)/
    @re_min_max = /(?<min>\d+|\?)[ ]*,[ ]*(?<max>\d+|\?)/
    @re_params = /(?<params>\[[ ]*((?<amount>\d+|\?)|(#{@re_min_max}))[ ]*\])/
    @re_add_params = /(?<params_add>\(([ ]|\S)*\))/

    @starts_with = /\+/
    @regex = /(?<regex>#{@starts_with}#{@re_type}(#{@re_params})?([ ]*#{@re_add_params}[ ]*)?([ ]*|\n)?(?<body>(\{\n([^{}]|\g<body>)*\}))?($|;))/

    # overwrite method to allow splitting into attributes and children
    def parse_content_raw(parser)
      elements = parser.parse(@content_raw)
      elements.each do |element|

        # correct line-numbers
        element.line_number += @line_number

        if element.kind_of?(Attribute)
          @attribs[element.name.to_sym] = element.value
        else
          element.parse_content_raw(parser)
          @children << element
        end
      end
    end

    # validates a given array of element of a page against this TemplateItem
    def validate(elements)

      # create ValidationItem to store validation-info
      @validation_item = ValidationItem.new(self)

      candidates = []

      if @collections.include?(@type)

        # skip validation if the collection is empty
        if !@children.empty?
           candidates = validate_collection(elements)

           # if a valid item has been found: check amount
           if @validation_item.valid?
             error = check_min_max_collection()
             # add error if broke out of min and max with valid items
             if !error.nil?
               @validation_item.add_error(error)
             end
           end
        end

      elsif @type == :element || @keywords.include?(@type)
        # find matching elements
        #(for type :element any type fits, only attributes care)
        candidates = validate_element(elements)
        valid_candidates = check_min_max(candidates)
        @validation_item.add_valid_elements(valid_candidates)

      else
        msg = "[#Template: #{@line_number}]"\
              "Error in template: '#{@type}' is not a valid element."
        error = ValidationError.new(-1, msg)
        @validation_item.add_error(error)
      end

      #create_errors_from_valid_candidates(valid_candidates)

      return @validation_item
    end

    def to_markup
      amount = [@min, 1].max
      element_str = ''
      element = nil

      if @collections.include?(@type)
        # handle collection
        element_str += collection_to_markup()
      else
        # handle element
        element_str += element_to_markup()
      end

      element_str += children_to_markup()

      opening_comment = Helper.create_comment(@type, @min, @max)
      closing_comment = Comment.new("", content_raw: "/#{@type.upcase} -----").to_markup
      markup = "#{opening_comment}\n#{element_str*amount}\n#{closing_comment}"

      return markup
    end

    private

      def init(params)
        # min, max will be set while parsing
        # default: min=1, max=-1 (-1 means '?' => no boundary)
        @min = params.fetch(:min, nil)
        @max = params.fetch(:max, nil)
        @attribs = params.fetch(:attributes, {})

        # Keywords should be provided as List of Element-classes
        # and are used to allow special Elements to be in a TemplateItem
        elements = params.fetch(:elements, Constants::ELEMENTS)
        element_keywords = elements.map {|el| el.new("").type}
        @additional_keywords = params.fetch(:additional_keywords, Constants::ADDITIONAL_KEYWORDS)
        @keywords = element_keywords.concat(@additional_keywords)
        @collections = params.fetch(:collections, Constants::COLLECTIONS)

        # will be created on validation only
        @validation_item = nil

        parse_template()
      end

      def parse_template
        match = self.class.regex.match(@raw)

        if !match.nil?
          if !match[:type].nil? && @type == :undefined
            @type = match[:type].to_sym
          end

          if !match[:subtype].nil? && @subtype == :undefined
            @subtype = match[:subtype].to_sym
            @attribs[:subtype] = @subtype.to_s
          end

          set_body(match)

          set_min_max(match)

        end
      end

      # sets attributes and children
      def set_body(match)
        if !match[:body].nil?
          @content_raw = match[:body].match(/\{\n((.|\s)*)\}/)[1]
        end
      end

      def set_min_max(match)
        # check parameter ([min, max] | [amount])
        if !match[:params].nil?
          min, max = min_max_params(match)
        else
          # check attributes (like "min: 5; max: 6" or "amount: 3")
          # or set default (= [1, -1])
          min, max = min_max_attributes(match)
        end

        if @min == nil
          @min = min_max_to_i(min)
        end

        if @max == nil
          @max = min_max_to_i(max)
        end
      end

      def min_max_params(match)
        if !match[:amount].nil?
          min = match[:amount]
          max = '?'
        else
          min = match[:min]
          max = match[:max]
        end
        return [min, max]
      end

      def min_max_attributes(match)
        # default values for min, max
        min = '1'
        max = '?'

        if !@attribs[:amount].nil?
          min = @attribs[:amount]
          # amount just specifies to expect at leat min elements,
          # so max isn't set
        else

          if !(@attribs[:min].nil?)
            min = @attribs[:min]
          end

          if !(@attribs[:max].nil?)
            max = @attribs[:max]
          end
        end

        return [min, max]
      end

      def min_max_to_i(str)
        int = -1
        if str != '?'
          # make sure it is a int and not smaller than -1
          int = [str.to_i, -1].max
        end
        return int
      end

      def validate_collection(elements)
  			# TODO: handle additional parameters for amount

        error = nil

        # validate the children
        suberrors = validate_children(elements)

  			case @type

  			when :any

          error = validate_any(suberrors)

  			when :order

          error = validate_order(suberrors)

  			end

  			return error

  		end

      def validate_children(elements)
        suberrors = []
        @children.each do |child|
          val_item = child.validate(elements)
          @validation_item.add_child(val_item)
          suberrors.concat(val_item.errors)
        end

        return suberrors
      end

      def validate_any(suberrors)

        error = nil
        valid = false

        # check if valid and generate list of all valid Elements
        @validation_item.children.each do |child|
          if child.valid?
            # first match has been found
            # -> valid
            valid = true
            # add the found elements to the valid elements list of the parent
            @validation_item.add_valid_elements(child.valid_elements)
          end
        end

        return error
      end

      def validate_order(suberrors)
        error = nil
        valid = false

        # generate the cartesian product of all valid items of the children
        product = generate_product()

        # distinguish strict and normal mode (strict = don't allow elements between the ones specified)
        strict = false
        if @attribs[:strict] == "true"
          strict = true
        end

        if all_children_valid?()
          valid_combinations = find_valid_combinations(product, strict)
          if !valid_combinations.empty?
            valid = true
            @validation_item.add_valid_elements(valid_combinations)
          end
        end

        if !valid && @min > 0
          str_msg = ""
          if strict
            str_msg = "(strict)"
          end
          msg = "[#Template: #{@line_number}] "
          msg += "The elements in collection \"order\" haven't"\
                  " been found in the correct#{str_msg} order."
          error = ValidationError.new(-1, msg, suberrors)
          @validation_item.add_error(error)
        end

        return error
      end

      def generate_product
        # create a list of all the valid items in all children
        valid_elements = []
        @validation_item.children.each do |child|
          valid_child_elements = child.valid_elements
          if !valid_child_elements.empty?
            valid_elements << valid_child_elements
          end
        end

        if !valid_elements.empty?
          first = valid_elements.shift
          product = first.product(*valid_elements)
        else
          product = []
        end

        return product
      end

      def all_children_valid?
        valid = true
        @validation_item.children.each do |child|
          if !child.valid?
            valid = false
            break
          end
        end
        return valid
      end

      def find_valid_combinations(product, strict)
        valid_combinations = []

        product.each do |combination|
          if is_valid_combination?(combination, strict)
            valid_combinations << combination
          end
        end

        return valid_combinations
      end

      def is_valid_combination?(combination, strict)
        valid = true

        # check that each element occurs after each other
        if !(combination.size < 2)
          last = combination.first
          (1..(combination.size - 1)).each do |i|
            this = combination[i]
            compare = last.compare_id(this)
            if compare == 1 || (strict && (!last.is_direct_successor?(this)))
              valid = false
              break
            end
            last = this
          end
        end

        return valid
      end

      def check_min_max_collection
        error = nil
        msg = nil

        valid_elements_size = @validation_item.valid_elements.size

        if (@min > 0 && valid_elements_size < @min)
          msg = "Did only find #{valid_elements_size} of #{@min} #{@type}(s))"
        end

        if (@max > -1 && valid_elements_size > @max)
          msg = "Does contain more than #{@max} #{@type}(s)"
        end

        if !msg.nil?
          msg = "[#Template: #{@line_number}] " + msg
          error = ValidationError.new(-1, msg)
        end

        return error
      end

      def validate_element(elements)
        # find all elements with matching type
        candidates = find_candidates(elements)

        # clean attributes
        clean_attribs = clean_attributes()

        # check attributes
        compare_attributes(candidates, clean_attribs)

        # check children
        validate_candidate_children(candidates)

        return candidates
      end

      # returns all elements that have the same type
      def find_candidates(elements)

        candidates = []

        # run DFS to check each element
        Helper.dfs(elements) do |element|
          # only add matching types (if type is :element thats all elements)
          if element.type == @type || @type == :element
            candidate = ValidationItem.new(self)
            candidate.add_valid_element(element)
            candidates << candidate
          end
        end

        return candidates
      end

      def clean_attributes
        # return only attributes that aren't used to specify validation_rules
        # and shouldn't exist in any element
        new_attribs = {}
        @attribs.each do |k, v|
          if !SPECIAL_ATTRIBUTES.include?(k)
            new_attribs[k] = v
          end
        end

        return new_attribs
      end

      def compare_attributes(candidates, attribs)

          candidates.each do |candidate|
            # get the real element of the candidate
            element = candidate.valid_elements.first

            attribs_can = element.attributes
            # Template-Attribute found in candidate?
            attribs.each do |k, v|
              if !attribute_equal?(attribs_can[k], v)
                # create error for each wrong attribute found:
                error_msg = "[#{element.line_number}] #{element.type.to_s}: "
                if attribs_can[k].nil?
                  error_msg += "#{k.to_s} not set"
                else
                  error_msg += "#{k.to_s} should be = '#{v.to_s}'"
                end
                error = ValidationError.new(attribs_can[:line_number], error_msg)
                candidate.add_error(error)
              end
            end
        end

        return candidates
      end

      def attribute_equal?(attr_candidate, attr_ti)
        equals = false
        if !attr_candidate.nil?
          if attr_candidate.instance_of?(String)
            equals = attr_candidate.strip == attr_ti.strip
          else
            # if attr_candidate is i.e. Fixum
            equals = attr_candidate.to_s == attr_ti.strip
          end
        end

        return equals
      end

      def validate_candidate_children(candidates)
        candidates.each do |candidate|
          can_childs = candidate.valid_elements.first.children
          # check child constraints of this TemplateItem on candidate-childs
          @children.each do |child_constraint|
            val_item = child_constraint.validate(can_childs)
            # add the ValidationItem to the candidate to be able to
            # extract errors and valid elements
            candidate.add_child(val_item)
          end
        end
      end

      # check if valid items are within the min-max bound
      def check_min_max(candidates)
        elements_matched = []

        valid_attributes = []
        valid = []

        error = nil
        sub_errors = []

        sort_candidates(candidates, valid, valid_attributes)

        msg = "[#Template: #{@line_number}] "

        error = check_min(valid, valid_attributes,
                          elements_matched, error, sub_errors, msg)

        error = check_max(valid, error, sub_errors, msg)

        if !error.nil?
          # set the error
          @validation_item.add_error(error)
        end

        # map ValidationItem[] to Element[]
        valid_elements = valid.map {|can| can.valid_elements.first }
        return valid_elements
      end

      def sort_candidates(candidates, valid, valid_attributes)
        candidates.each do |candidate|
          if candidate.errors.empty?
            valid_attributes << candidate
            if candidate.get_child_errors.empty?
              valid << candidate
            end
          end
        end
      end

      def check_min(valid, valid_attributes, elements_matched, error, sub_errors, msg)

        if !(valid.size >= @min || @min == -1)
          # add all valid candidates to result-list
          elements_matched.concat(valid)
          if valid_attributes.size > 0
            # fill result-list with valid_attributes
            valid_attributes.sort! {|a, b| a.get_child_errors <=> b.get_child_errors }
            while elements_matched.size < @min && !valid_attributes.empty?
              element = valid_attributes.shift
              elements_matched << element
              # add child-errors to errors list
              sub_errors.concat(element.get_child_errors)
            end
          end

          msg_sub = ''
          if !@subtype.nil? && @subtype != :undefined
            msg_sub = " and subtype '#{@subtype}'"
          end

          # create error
          if valid.empty?
            msg += "No element(s) of type '#{@type}'#{msg_sub} found."
          else
            msg += "Only found #{valid.size} of #{@min} elements of type '#{@type}'#{msg_sub}."
          end

          pos = -1
          if elements_matched.size > 0
            # find first match with invalid children
            elements_matched.each do |el|
              if el.get_child_errors.size > 0
                pos = el.valid_elements.first.line_number
              end
            end
          end
          error = ValidationError.new(pos, msg, sub_errors)
        end

        return error
      end

      def check_max(valid, error, sub_errors, msg)

        if !(valid.size <= @max || @max == -1)
          msg += "Found too many elements of type '#{@type}' (#{valid.size} of #{@max})."
          # get line_number of first additional element
          sorted = valid.map {|can| can.valid_elements.first.line_number }
          sorted = sorted.sort
          error = ValidationError.new(sorted[@max + 2], msg, sub_errors)
        end

        return error
      end

      def collection_to_markup
          str = ''

          case @type
          when :any
            str = 'Any element can be picket and (within the bounds) exist multiple times.'
          when :order
            str = 'Every item needs to appear in the correct order.'
            if @attribs[:strict].to_s == true.to_s
              str += "\nSTRICT mode: No other elements are allowed between them."
            end
          end

          collection_comment = Comment.new('', content_raw: str).to_markup

          return collection_comment
      end

      def element_to_markup
        element_str = ''

        fill = ''
        if @type == :string
          if !@attribs[:raw].nil?
            raw = @attribs[:raw]
          else
            raw = 'some_string'
          end
          raw += ' '
          element = Element.new(raw, type: @type)
        elsif @type == :newline
          raw = "\n"
          element = Element.new(raw, type: @type)
        else
          params = clean_attributes()
          element_class = Helper.find_element_class(self)
          if element_class.nil?
            # not a valid TemplateItem type
            str = "#{@type.upcase} is an invalid element type.\n Check template."
            element = Comment.new('', content_raw: str)
          else
            element = element_class.new("", params)
          end
          fill = "\n"
        end

        element_str += "#{element.to_markup}#{fill}"
        return element_str
      end

      def children_to_markup
        children_str = ''
        @children.each do |child|
          children_str += "\n#{child.to_markup}\n"
        end
        return children_str
      end

  end

end
