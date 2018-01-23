$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'
module WikiValidator

  class Link < Element

    attr_reader :link, :triple, :predicate, :namespace, :page, :object

    class << self; attr_reader :regex_triple end

    external = /(?<lb>\[)(?<link>[^\]$]*)(?<rb>\])/
    internal = /(?<lb>\[{2})(?<link>[^\]$]*)(?<rb>\]{2})/
    @regex = /\A#{internal}|#{external}/
    @starts_with = /\[/
    @regex_triple = /\A([^:]+?)::([^:]+):([^:\s]+)/

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
      if @subtype == :internal || @subtype == :triple
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
            match_triple()
          end

        else
          set_params(params)
        end
      end

      def create_content_str
        str = ''
        str_link = ''
        if @content_raw != ''
          str = @content_raw
        elsif (@subtype == :triple) && (!@predicate.nil? || !@object.nil? || !@namespace.nil? || !@page.nil?)
          predicate = @predicate
          if predicate == ''
            predicate = Comment.new('', content_raw: "Any predicate").to_markup
          end
          object = @object
          if object == ''
            namespace = @namespace
            page = @page
            if namespace == ''
              namespace = Comment.new('', content_raw: "Any namespace").to_markup
            end

            if page == ''
              page = Comment.new('', content_raw: "Any page name").to_markup
            end

            object = "#{namespace}:#{page}"
          end
          str_link = " => #{predicate}::#{object}"
        end
        if str == ''
          str = Comment.new('', content_raw: "Put #{@subtype} link here").to_markup
        end

        return str
      end

      def match_triple
        if @link.match(self.class.regex_triple)
          @subtype = :triple
          @predicate = $1
          @namespace = $2
          @page = $3
          @object = "#{@namespace}:#{@page}"
          @triple = [$1, $2, $3]
        else
          @subtype = :internal
        end
      end

      def set_params(params)
        @link = params.fetch(:link, '')
        @triple = params.fetch(:triple, nil)
        @predicate = params.fetch(:predicate, nil)
        @object = params.fetch(:object, nil)
        @namespace = params.fetch(:namespace, nil)
        @page = params.fetch(:page, nil)

        if @content_raw != '' && @link == ''
          @link = @content_raw
        end
      end
  end

end
