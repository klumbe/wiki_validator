require 'spec_helper'

describe WikiValidator::Attribute do

  describe '#new' do
    it 'takes a string and returns a new Attribute' do
      str = '|key: value'
      attribute = WikiValidator::Attribute.new(str)
      expect(attribute).to be_an_instance_of(WikiValidator::Attribute)
      expect(attribute.name).to eq('key')
      expect(attribute.value).to eq('value')
    end
  end
end
