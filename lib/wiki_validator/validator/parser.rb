$LOAD_PATH << File.dirname(__FILE__)

require 'elements/section.rb'
require 'content_parser.rb'

module WikiValidator

  class Parser

    def initialize(params = {})
  		@DEFAULT_ELEMENTS = Constants::ELEMENTS
      @DEFAULT_CONSTRAINTS = Constants::CONSTRAINTS
  		@DEFAULT_IGNORE = Constants::IGNORED
      elements = params.fetch(:elements, @DEFAULT_ELEMENTS)
      constraints = params.fetch(:constraints, @DEFAULT_CONSTRAINTS)
      ignore = params.fetch(:ignore, @DEFAULT_IGNORE)

      @content_parser = ContentParser.new(elements, ignore, {skip: [:newline]})
  		@constraint_parser = ContentParser.new(constraints, ignore, {skip: [:newline]})
    end

    def parse_content(string, params = {})
      parameter = {
        sectioning: params.fetch(:sectioning, true),
        return: params.fetch(:return, :default),
        set_ids: params.fetch(:set_ids, true),
      }
      elements = parse(@content_parser, string)
      elements = deep_parse(elements, @content_parser)
      processed_elements = process_elements(elements, parameter)

      return processed_elements
    end

  	def parse_constraints(string, params = {})
      parameter = {
        sectioning: params.fetch(:sectioning, false),
        return: params.fetch(:return, :default),
        set_ids: params.fetch(:set_ids, false),
      }
      elements = parse(@constraint_parser, string)
      elements = deep_parse(elements, @constraint_parser)
      processed_elements = process_elements(elements, parameter)

      return processed_elements
  	end

  	private

      def parse(parser, string)
        elements = parser.parse(string)

        return elements
      end

      def deep_parse(elements, parser)
        # parse the inner part of an element
        elements.each do |element|
          element.parse_content_raw(parser)
        end
        return elements
      end

      def process_elements(elements, params = {})
        if (params[:sectioning] || params[:return] == :sections)
          sections = handle_sectioning(elements)
        end

        # set IDs that help to identify the order
        if (params[:set_ids])
          set_ids(elements)
        end

        if params[:return] == :sections
          return sections
        else
          return elements
        end
      end

  		# puts elements (and subsections) as childs of their parent section
  		def handle_sectioning(elements)
  			sections = []
  			section_stack = []

  			elements.each do |el|
          insert_element(el, sections, section_stack)
  			end

  			return sections
  		end

      def insert_element(element, sections, section_stack)
        if element.instance_of?(Section)
          nested = nest_section(section_stack, element)

          if !nested && !sections.include?(element)
            sections << element
          end

        else
          if section_stack.empty?
            sections << element
          else
            # add element to the latest known section
            section_stack.last.add_child(element)
          end
        end
      end

      def nest_section(section_stack, section)
        nested = false
        # remove processed sections from stack
        clean_stack(section_stack, section)

        # add section as a child
        if !section_stack.empty?
          section_stack.last.add_child(section)
          nested = true
        end
        section_stack << section

        return nested
      end

      def clean_stack(section_stack, section)
          # remove all deeper and same level subsections from stack
          while (!section_stack.empty? && section_stack.last.attributes[:level] >= section.attributes[:level])
            section_stack.pop
          end
      end

      # sets IDs of the form "1_2_1" which is the id of the parent concatenated
      # with a new ID for the element
      def set_ids(elements, visited = [],  parent = '')
        num = 1

        elements.each do |el|
          if !visited.include?(el)
            id = "#{parent}#{num}"
            el.set_id(id)
            visited << el
            set_ids(el.children, visited, "#{id}_")
            num += 1
          end
        end
      end

  end
end
