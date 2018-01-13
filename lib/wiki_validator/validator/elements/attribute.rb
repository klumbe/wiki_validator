$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'

module WikiValidator

  # class only used to parse Attributes of TemplateItems
  class Attribute < Element
    attr_reader :name, :value

    # |name: value
    @regex = /\|(?<attribute>\w+):[ ]*(?<value>[^\n;$]*)/
    @starts_with =/\|/

    private

      def init(params)
        @type = :attribute

        match = Attribute.regex.match(@raw)

        if !match.nil?
          @name = match[:attribute]
          @value = match[:value]
        end
      end
  end

end
