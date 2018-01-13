require "bundler/setup"
require "wiki_validator"

# set short-links for modules classes:

Constants = WikiValidator::Constants

Attribute = WikiValidator::Attribute
Comment = WikiValidator::Comment
Element = WikiValidator::Element
Helper = WikiValidator::Helper
Link = WikiValidator::Link
List = WikiValidator::List
Section = WikiValidator::Section
Table = WikiValidator::Table
Tag = WikiValidator::Tag
TemplateItem = WikiValidator::TemplateItem

PageDTO = WikiValidator::PageDTO
ValidationError = WikiValidator::ValidationError
ValidationItem = WikiValidator::ValidationItem
ValidationStatus = WikiValidator::ValidationStatus

Parser = WikiValidator::Parser
Validator = WikiValidator::Validator

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
