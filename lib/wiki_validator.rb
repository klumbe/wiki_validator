require "wiki_validator/version"

require 'wiki_validator/validator/validator'
require 'wiki_validator/validator/parser'
require 'wiki_validator/validator/helper'
require 'wiki_validator/constants'

module WikiValidator

  class WikiValidator

    attr_reader :page, :templates

    TEMPLATE_VARIABLES = [ 'template_name',
                           'template_namespace',
                           'page_name',
                           'page_namespace',
                        ]
    TEMPLATE_IDENTIFIER = /validatedBy/i

    def initialize(params = {})
      @parameter = params
      @parameter[:parser] = @parameter[:parser] || {}
      # create parser with optional parameters
      parser_params = params.fetch(:parser, {})
      @parser = Parser.new(parser_params)

      @page = nil
      @templates = []
    end

    def set_page(page_dto)
      if page_dto.instance_of?(PageDTO)
        @page = parse_page(page_dto)
      end
    end

    def parse_page(page_dto)
      if page_dto.instance_of?(PageDTO)
        page_dto.ast = @parser.parse_content(page_dto.content_string, @parameter[:parser])
      end

      return page_dto
    end

    def add_template(template_dto)
      if template_dto.instance_of?(PageDTO)
        @templates << template_dto
      end
    end

    def add_templates(template_list)
      if template_list.instance_of?(Array)
        template_list.each do |template|
          add_template(template)
        end
      end
    end

    def parse_template(template_dto)
      if template_dto.instance_of?(PageDTO)
        content = template_dto.content_string
        template_dto.ast = @parser.parse_constraints(content, @parameter[:parser])
      end

      return template_dto
    end

    # finds all triplets used to specify the applied templates
    def extract_template_names
      templates = []

      Helper.dfs(@page.ast) do |element|
        if element.type == :link && element.subtype == :triplet
          if element.triplet.first.match(TEMPLATE_IDENTIFIER)
            triplet = element.triplet
            templates << "#{triplet[1]}:#{triplet[2]}"
          end
        end
      end

      return templates
    end

    # generates a page from a given template and
    # the parameters of the page that needs to be generated (encapsulated in a PageDTO)
    def generate_page(template_dto, page_dto)
      page = PageDTO.new('','', '')

      if template_dto.instance_of?(PageDTO) && page_dto.instance_of?(PageDTO)
        variables = extract_variables(template_dto, page_dto)
        template_content_str = replace_variables(template_dto.content_string, variables)
        template_dto.ast = @parser.parse_constraints(template_content_str, @parameter[:parser])

        # generate the markup
        page_content_str = ''
        template_dto.ast.each do |constraint|
          page_content_str += constraint.to_markup + "\n"
        end

        page = PageDTO.new(page_dto.name, page_dto.namespace, page_content_str)

      end

      return page
    end

    def validate
      validation_status = []
      @templates.each do |template|
        replace_template_content(template)
        parse_template(template)
        status = Validator.validate(@page, template)
        validation_status << status
      end

      return validation_status
    end

    private

      def extract_variables(template_dto, page_dto)
        variables = {
            'template_name' => template_dto.name,
            'template_namespace' => template_dto.namespace,
            'page_name' => page_dto.name,
            'page_namespace' => page_dto.namespace,
        }

        return variables
      end

      def replace_variables(str, variables)
        replaced = str
        variables.each do |k, v|
          var = "$(#{k})"
          replaced.gsub!(var, v)
        end

        return replaced
      end

      def replace_template_content(template)
        variables = extract_variables(template, @page)
        replaced_content = replace_variables(template.content_string, variables)
        template.content_string = replaced_content
      end

    end

end
