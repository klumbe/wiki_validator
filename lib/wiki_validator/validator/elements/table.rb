$LOAD_PATH << File.dirname(__FILE__)
require 'element.rb'

module WikiValidator

  class Table < Element
    # kept simple because it is rarely used
    # can be extended by implementing a equals? method

    attr_reader :rows

    @regex = /\A(?<open>^\{\|$\n)(?<lines>(^.*?$\n)+)(?<close>^\|\})/
    @starts_with = /^\[\|$\n/

    def to_markup
      markup = ""
      rows = ""
      @rows.each do |row|
        rows += "|-\n"
        row.each {|col| rows += "|#{col}\n"}
      end
      
      markup = "{|\n#{rows}\n|}"
    end

    private

      def init(params)
        @type = :table
        match = Table.regex.match(@raw)
        if match
          @content_raw = match[:lines]
          @rows = split_lines()
        else
          @rows = []
        end
      end

      def split_lines
        lines = @content_raw.split(/\|-$\n/)
        rows = []

        lines.each do |line|
          if !(line == '')
            cells = line.split('|')
            cells.select! {|c| c != ''}
            rows << cells
          end
        end

        return rows
      end
  end

end
