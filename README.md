# WikiValidator

This gem is designed to be used by the 101wiki (https://github.com/101companies/101rails) to validate the structure of a page against a given validator page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wiki_validator', git: 'https://github.com/klumbe/wiki_validator.git'
```

And then execute:

    $ bundle

## Usage

After installing the gem, one needs to create a WikiValidator-Instance:

    validator = WikiValidator::WikiValidator.new

Create a data transfer object to store the information of a page:

    page_dto = WikiValidator::PageDTO.new('page_name', 'page_namespace', 'page_content_string')

Assign the page to the validator:

    validator.set_page(page)

Extract the names of the templates validating the page:

    template_names = validator.extract_template_names()

Find the template in the wiki and transform them to DTOs:

    templates = fetch_from_database(template_names)
    template_dtos = []
    templates.each do |t|
      template_dtos << PageDTO.new(...)
    end

Add the template DTOs to the validator:

    validator.add_templates(template_dtos)

Validate the page against the templates and get a list with a ValidationStatus for every template:

    validation_status_list = validator.validate()

Check the status for a template:

    valid = validation_status_list.first.valid?

And list the errors if not valid:

    errors = validation_status_list.first.errors

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/klumbe/wiki_validator.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
