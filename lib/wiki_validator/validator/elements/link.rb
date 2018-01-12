$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'
module WikiValidator

  class Link < Element

    attr_reader :link, :triplet

    external = /(?<lb>\[)(?<link>[^\]$]*)(?<rb>\])/
    internal = /(?<lb>\[{2})(?<link>[^\]$]*)(?<rb>\]{2})/
    @regex = /\A#{internal}|#{external}/
    @starts_with = /\[/

    #override method to do nothing
    def parse_content_raw(content_parser); end

    def equals?(element)
      equal = false

      if element.kind_of?(Link) && element.type == @type
        if element.subtype == @subtype && element.link == @link
          equal = true
        end
      end

      return equal
    end

    def to_markup

      str = create_content_str()
      markup = "[#{str}]"
      if @subtype == :internal || @subtype == :triplet
        markup = "[#{markup}]"
      end

      return markup
    end

    private

      def init(params)
        @type = :link
        match = Link.regex.match(@raw)

        if match
          @link = match[:link]
          @content_raw = @link

          if match[:lb].length == 1
            @subtype = :external

          else
            match_triplet()
          end

        else
          @link = params.fetch(:link, '')
          if @content_raw != '' && @link == ''
            @link = @content_raw
          end
        end
      end

      def create_content_str
        str = @content_raw
        if str == ''
          str = Comment.new('', content_raw: "Put #{@subtype} link here").to_markup
        end

        return str
      end

      def match_triplet
        triplet = /\A([^:]*?)::(.*)/

        if @link.match(triplet)
          @subtype = :triplet
          @triplet = [$1, $2]
        else
          @subtype = :internal
        end
      end
  end

end
