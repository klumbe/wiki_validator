module WikiValidator

  # used to store both the Element from the template
  # and the found matches, errors
  class ValidationItem

    # template_item = element to use as constraint
    # valid_elements = list of found matches (if no collection)
    # errors = List of ValidationErrors
    # children = List of results (ValidationItems) for the children of the template_item
    attr_reader :template_item, :valid_elements, :errors, :children

    def initialize(template_item)
      @template_item = template_item
      @valid_elements = []
      @errors = []
      @children = []
    end

    def add_valid_element(element)
      @valid_elements << element
    end

    def add_valid_elements(elements)
      @valid_elements.concat(elements)
    end

    def add_error(error)
      @errors << error
    end

    def add_child(child)
      @children << child
    end

    def get_child_errors
      errors = []
      @children.each do |child|
        errors.concat(child.errors)
      end
      return errors
    end

    def valid?
      return @errors.empty?
    end

  end

end
