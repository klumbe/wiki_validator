$LOAD_PATH << File.dirname(__FILE__)

Dir[File.expand_path("elements/*.rb", File.dirname(__FILE__))].each do |file|
  require file
end

require 'strscan'

module WikiValidator

  class ContentParser

    def initialize(element_array, ignore_array, params={})
      # ordered list of elements which are to parse
      @elements = element_array
      @ignored_elements = ignore_array
      @params = params

      # set default parameters
      if @params[:skip].nil?
        @params[:skip] = []
      end
    end

    def parse(content_string)
      buffer = StringScanner.new(content_string)

  		# list of elements returned by the parser
      content = []

      # latest found element (can be a skipped one, too)
      last_element = nil

  		# list of all elements known by the parser
      all_elements = ([].concat(@ignored_elements)).concat(@elements)
      string_regex = build_string_regex(all_elements)

      line_count = 1

      until buffer.eos?
        matched = false

        # skip ignored elements
        @ignored_elements.each do |ie|
          if buffer.match?(ie.regex)
            str = buffer.scan(ie.regex)
            last_element = ie.new(str, line_number: line_count)
            line_count += str.count("\n")
            matched = true
            break
          end
        end

        # try to match an element
        if !matched
          @elements.each do |e|
            skip = false
            if new_line_needed?(e)
              if !last_element.nil? && !ends_with_new_line?(last_element)
                skip = true
              end
            end
            if !skip && buffer.match?(e.regex)
              s = buffer.scan(e.regex)
              el = e.new(s, line_number: line_count)
              line_count += s.count("\n")

              # parse one step deeper
              if !el.attributes[:content_raw].nil?
                el.attributes[:content] = parse(el.attributes[:content_raw])
              end
              content << el
              last_element = el
              matched = true
              break
            end
          end
        end

        # try to match a string if no element has been found
        if !matched
          if buffer.match?(string_regex)
            # special case (string concatenated with element without space)
            s = buffer.scan(string_regex)
          else
            s = buffer.scan(/\S+/)
          end

          if !s.nil?
            params = {type: :string, line_number: line_count}
            el = Element.new(s, params)
            if !@params[:skip].include?(:string) && !s.nil?
              content << el
            end
            last_element = el
          end
        end

        # skip spaces and tabs
        buffer.scan(/( |\t)*/)

        # detect newlines
        if buffer.match?(/\n/)
          n = buffer.scan(/\n/)
          el = Element.new(n, type: :newline, line_number: line_count)
          if !@params[:skip].include?(:newline)
            content << el
          end
          last_element = el
          line_count += 1
        end
      end

      return content
    end

    private

  		# builds a string-regex based on exclusion of elements
      def build_string_regex(elements)

        starting_with = ""
        elements.each_with_index do |el, i|
           starting_with += el.starts_with.to_s
           if i < elements.size - 1
             starting_with += "|"
           end
        end

        string_regex = /\A[^\s]+?(?=(#{starting_with}))/
      end

      def new_line_needed?(element)
        needed = false
        if element.starts_with.to_s.match(/\(*\^/)
          needed = true
        end
        needed
      end

      def ends_with_new_line?(element)
        ewnl = false
        if element.raw.match(/.*\n/)
          ewnl = true
        end

        return ewnl
      end
  end

end
