$LOAD_PATH << File.dirname(__FILE__)
Dir[File.expand_path("./validator/elements/*.rb", File.dirname(__FILE__))].each do |file|
  require file
end

module WikiValidator

  class Constants
    # Valid Symbols to use for Template-Collections:
    COLLECTIONS = [:any, :order]
    # Valid Elements used for regular pages (order counts!):
    ELEMENTS = [Tag, Link, List, Table, Section]
    # Valid Elements used for templates (order counts!):
    CONSTRAINTS = [TemplateItem, Attribute, Tag, Link, List, Table, Section]
    # Elements that should be recognized but not included in the parser-output:
    IGNORED = [Comment]
    # List of Types of the ELEMENTS-constant
    ELEMENT_KEYWORDS = ELEMENTS.map {|el| el.new("").type}
    # Additional keywords where no Element has been created for
    ADDITIONAL_KEYWORDS = [:string, :newline]
    # Complete list of keywords
    KEYWORDS = ELEMENT_KEYWORDS.concat(ADDITIONAL_KEYWORDS)
  end

end
