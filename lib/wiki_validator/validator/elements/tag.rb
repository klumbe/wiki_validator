$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'

module WikiValidator

  class Tag < Element

    attr_reader :tag, :attribs_raw, :attribs

    @regex = /\A<\s*([^\s\/>]+)\s*(([^\/>]*)(\/>|(>([^<]*)<\/\1>)))/
    @starts_with = /<\w/

    def equals?(element)
      equal = false
      if element.kind_of?(Tag) && element.type == @type
        if (element.tag == @tag) && (element.content_raw == @content_raw)
          if attribs_equal?(element)
            equal = true
          end
        end
      end
      return equal
    end

    def to_markup
      attr_str = @attribs.reduce("") {|a| " #{a.to_s}"}
      tag = @tag
      if tag == ''
        tag = Comment.new('', content_raw: 'tag-type').to_markup
      end
      return "<#{tag}#{@attr_str}>\n#{@content_raw}\n</#{tag}>"
    end

    private

      def init(params)
        @type = :tag
        @tag = ""
        @attribs_raw = ""
        @attribs = []

        match = Tag.regex.match(@raw)
        if match
          @tag = $1.strip
          @subtype = @tag.downcase.to_sym
          if !$4.nil?
            @attribs_raw = $3
            @attribs = $3.split
          end
          @content_raw = $6 || ""
        else
          set_params(params)
        end
      end

      def attribs_equal?(element)
        equal = true

        if element.attribs.size == @attribs.size
          @attribs.each do |attr|
            if !element.attribs.include?(attr)
              equal = false
              break
            end
          end
        end

        return equal
      end

      def set_params(params)
        @tag = params.fetch(:tag, "")
        @attribs_raw = params.fetch(:attribs_raw, "")
        @attribs = params.fetch(:attribs, [])
      end
  end

end
