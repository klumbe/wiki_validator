$LOAD_PATH << File.dirname(__FILE__)
require "element.rb"

module WikiValidator

  class List < Element

    attr_reader :level

    @regex = /^([#\*:;]+)[^\n\S]*(.*)$/
    @starts_with = /^[#\*:;]/

    def equals?(element)
      equal = false
      if element.kind_of?(List) && element.type == @type
        if element.subtype == @subtype && element.level == @level
          if element.content_raw == @content_raw
            equal = true
          end
        end
      end
      return equal
    end

    def to_markup
      return "#{@raw[0]*@level} #{@content_raw}"
    end

    private

      def init(params)
        @type = :list
        match = List.regex.match(@raw)
        if match
          @level = $1.length
          @content_raw = $2.strip
          symbol = $1[0]
          set_subtype(symbol)
        end
      end

      def set_subtype(symbol)

        case symbol
        when '#'
          @subtype = :enumeration
        when '*'
          @subtype = :bullet
        when ':'
          @subtype = :indent
        when ';'
          @subtype = :definition
        end
      end
  end

end
