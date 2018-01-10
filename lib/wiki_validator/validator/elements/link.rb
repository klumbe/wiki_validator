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
  end

end
