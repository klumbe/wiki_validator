require 'spec_helper'

describe WikiValidator::ValidationItem do

  before :each do
    @template_item = TemplateItem.new("+string")
    @validation_item = ValidationItem.new(@template_item)
  end

  describe '#new' do
    it 'takes a TemplateItem as parameter and returns ValidationItem' do
      template_item = TemplateItem.new('+section')
      val_item = ValidationItem.new(template_item)
      expect(val_item).to be_an_instance_of(ValidationItem)
      expect(val_item.template_item).to eq(template_item)
      expect(val_item.valid_elements).to be_an_instance_of(Array)
      expect(val_item.valid_elements.size).to eq(0)
      expect(val_item.errors).to be_an_instance_of(Array)
      expect(val_item.errors.size).to eq(0)
      expect(val_item.children).to be_an_instance_of(Array)
      expect(val_item.children.size).to eq(0)
    end
  end

  describe '#add_valid_element' do
    it 'takes an Element and adds it to valid_elements list' do
      expect(@validation_item.valid_elements.size).to eq(0)
      @validation_item.add_valid_element(Element.new("str"))
      expect(@validation_item.valid_elements.size).to eq(1)
    end

  end

  describe '#add_valid_elements' do
    it 'takes a list of Elements and adds it to valid_elements list' do
      expect(@validation_item.valid_elements.size).to eq(0)
      valid_elements = [Element.new("str"), Element.new("Str2")]
      @validation_item.add_valid_elements(valid_elements)
      expect(@validation_item.valid_elements.size).to eq(2)
    end
  end

  describe '#add_error' do
    it 'takes a ValidationError and adds it to  errors list' do
      expect(@validation_item.errors.size).to eq(0)
      @validation_item.add_error(ValidationError.new(-1, 5, 'message'))
      expect(@validation_item.errors.size).to eq(1)
    end
  end

  describe '#add_child' do
    it 'takes an Element and adds it as a child' do
      expect(@validation_item.children.size).to eq(0)
      @validation_item.add_child(ValidationItem.new(@template_item))
      expect(@validation_item.children.size).to eq(1)
    end
  end

  describe '#valid?' do
    it 'returns true if the ValidationItem does not contain errors' do
      expect(@validation_item.valid?).to eq(true)
    end

    it 'returns false if the ValidationItem contains errors' do
      @validation_item.add_error(ValidationError.new(-1, 4, 'message'))
      expect(@validation_item.valid?).to eq(false)
    end
  end
end
