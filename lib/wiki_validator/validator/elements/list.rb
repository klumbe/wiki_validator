$LOAD_PATH << File.dirname(__FILE__)
require "element.rb"

module WikiValidator

  class List < Element

    attr_reader :level

    @regex = /^([#\*:;]+)(.*)$/
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
      str = @content_raw
      if str == ''
        # create placeholder to inform the user what is expected here
        str = Comment.new('', content_raw: 'Put your list string here.').to_markup
      end
      return "#{get_symbol()*@level}#{str}"
    end

    private

      def init(params)
        @type = :list
        match = List.regex.match(@raw)
        if match
          @level = $1.length
          @content_raw = $2
          symbol = $1[0]
          set_subtype(symbol)
        else
          @level = params.fetch(:level, 1).to_i
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

      def get_symbol

        symbol = ''
        case @subtype
        when :enumeration
          symbol = '#'
        when :indent
          symbol = ':'
        when :definition
          symbol = ';'
        else
          symbol = '*'
        end

        return symbol
      end

  end

end
