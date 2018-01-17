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

    def to_markup
      comment_before = ''
      str = @title
      if str == ''
        str = Comment.new('', content_raw: 'Put your section title here.').to_markup
      end

      count = @level
      if @level == -1
        count = 1
        comment = Comment.new('', content_raw: 'Change section level as needed:')
        comment_before = "#{comment.to_markup}\n"
      end
      lev = '='*count
      markup = "#{comment_before}#{lev}#{str}#{lev}"
      return markup
    end

    private

      def init(params)
        @type = :section

        match = Section.regex.match(@raw)

        if !match.nil?
          @level = $1.length
          @title = $2.strip
        else
          # set initial values either from params or default
          # in case the section does not match
          @level = params.fetch(:level, -1).to_i
          @title = params.fetch(:title, '')
        end
      end

  end

end
