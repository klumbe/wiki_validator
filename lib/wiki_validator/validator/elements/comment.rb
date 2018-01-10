$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'

module WikiValidator

  class Comment < Element

    @regex = /<!--\s(?<comments>(.|\s)*?)\s-->\n?/
    @starts_with = /<!--/

    private

      def init(params)
        @type = :comment

        match = Comment.regex.match(@raw)
        if match
          @content_raw = match[:comments]
        end
      end
  end

end
