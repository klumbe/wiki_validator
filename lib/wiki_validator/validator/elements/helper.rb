module WikiValidator

  class Helper

    # returns the class of a TemplateItems type
    def self.find_element_class(template_item)
      element_class = nil
      Constants::ELEMENTS.each do |el|
        name = el.name.split('::').last
        if name.downcase.to_sym == template_item.type
          element_class = el
          break
        end
      end

      return element_class
    end

    # returns comment-markup for TemplateItems
    def self.create_comment(type, min, max)
      comment_str = "#{type.upcase} "

      case
      when min == -1 && max == -1
        comment_str += "is optional and can appear as often as one likes."
      when min == -1 && max != -1
        comment_str += "must not appear more often than #{max} times."
      when min != -1 && max == -1
        comment_str += "have to exist at least #{min} times."
      when min != -1 && max != -1 && min == max
        comment_str += "have to exist exactly #{min} times."
      when min != -1 && max != -1
        comment_str += "have to exist between #{min} and #{max} times."
      end

      comment = Comment.new("", content_raw: comment_str)

      return comment.to_markup
    end

  end

end
