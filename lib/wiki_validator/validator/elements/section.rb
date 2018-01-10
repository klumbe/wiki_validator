$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'

module WikiValidator

  class Section < Element

    attr_reader :level, :title

    @regex = /^(={1,6})(.+?)(\1\n?|$)/
    @starts_with = /^(={1,6})/

    def equals?(element)
      equal = false
      if element.kind_of?(Section) && (element.type == @type)
        if (element.level == @level) && (element.title == @title)
          equal = true
        end
      end
      return equal
    end

    private

      def init(params)
        @type = :section

        match = Section.regex.match(@raw)

        if !match.nil?
          @level = $1.length
          @title = $2.strip
          @content_raw = @title
        else
          # set initial values either from params or default
          # in case the section does not match
          @level = params.fetch(:level, -1)
          @title = params.fetch(:title, '')
        end
      end

  end

end
