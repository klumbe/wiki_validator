require 'spec_helper'

describe WikiValidator::Element do

  describe '#new' do
    it 'takes any string and returns element with undefined type' do
      element = Element.new("")
      expect(element).to be_an_instance_of(Element)
      expect(element.type).to eq(:undefined)
      expect(element.raw).to eq("")
      expect(element.id).not_to eq("")
    end

    it 'takes a hash and initialises its attributes' do
      params = {id: '1_2_3',
        type: :string,
        subtype: :string,
        line_number: 5,
        content_raw: 'String_new',
        children: [Element.new("")],
       }
      element = Element.new("String", params)
      expect(element.id).to eq('1_2_3')
      expect(element.type).to eq(:string)
      expect(element.type).to eq(:string)
      expect(element.line_number).to eq(5)
      expect(element.content_raw).to eq('String_new')
      expect(element.children.size).to eq(1)
    end
  end

  describe '#set_id' do
    it 'changes the id' do
      el = Element.new("")
      id = el.id
      el.set_id("3_4")
      expect(el.id).not_to eq(id)
      expect(el.id).to eq("3_4")
    end
  end

  describe '#parent_id' do
    it 'returns the id of the parent if id is set correctly' do
      el = Element.new("String", id: '1_2')
      expect(el.parent_id).to eq('1')
    end

    it 'returns empty string if not set correctly or has no parent' do
      el = Element.new("Invalid")
      el2 = Element.new("NoParent", id: '1')
      expect(el.parent_id).to eq('')
      expect(el2.parent_id).to eq('')
    end
  end

  describe '#compare_id' do

    before :all do
      @element = Element.new('Element 1', id: '1_2_3')
      @element2 = Element.new('Element 2', id: '1_2_5')
      @element3 = Element.new('Element 3', id: '2_2_3')
      @invalid_element = Element.new('Invalid Element')
    end

    it 'takes another element with wrong id and returns -2' do
      compare = @element.compare_id(@invalid_element)
      expect(compare).to eq(-2)
    end

    it 'has invalid id and takes another element with correct and returns -2' do
      compare = @invalid_element.compare_id(@element)
      expect(compare).to eq(-2)
    end

    it 'takes another element with higher id and returns -1' do
      compare1 = @element.compare_id(@element2)
      compare2 = @element.compare_id(@element3)
      compare3 = @element2.compare_id(@element3)
      expect(compare1).to eq(-1)
      expect(compare2).to eq(-1)
      expect(compare3).to eq(-1)
    end

    it 'takes another element with the same id and returns 0' do
      compare = @element.compare_id(@element)
      expect(compare).to eq(0)
    end

    it 'takes another element with a lower id and returns 1' do
      compare1 = @element3.compare_id(@element)
      compare2 = @element3.compare_id(@element2)
      compare3 = @element2.compare_id(@element)
      expect(compare1).to eq(1)
      expect(compare2).to eq(1)
      expect(compare3).to eq(1)
    end
  end

  describe '#is_direct_successor?' do

    before :all do
        @element = Element.new('', id: '1_3_4')
        @element2 = Element.new('', id: '1_3_6')
        @element3 = Element.new('', id: '1_2_5')
        @element4 = Element.new('', id: '1_3_5')
        @element5 = Element.new('', id: '2_3_4')
        @invalid_element = Element.new('')
    end

    it 'takes another element with wrong id and returns false' do
      successor = @element.is_direct_successor?(@invalid_element)
      expect(successor).to eq(false)
    end

    it 'has a wrong id and returns false' do
      successor = @invalid_element.is_direct_successor?(@element)
      expect(successor).to eq(false)
    end

    it 'takes a no direct successor and returns false' do
      successor1 = @element.is_direct_successor?(@element2)
      successor2 = @element.is_direct_successor?(@element3)
      successor3 = @element.is_direct_successor?(@element5)
      successor4 = @element.is_direct_successor?(@element)
      expect(successor1).to eq(false)
      expect(successor2).to eq(false)
      expect(successor3).to eq(false)
      expect(successor4).to eq(false)
    end

    it 'takes a direct successor and returns true' do
      successor1 = @element.is_direct_successor?(@element4)
      successor2 = @element4.is_direct_successor?(@element2)
      expect(successor1).to eq(true)
      expect(successor2).to eq(true)
    end
  end

  describe '#add_child' do

    before :each do
      @parent = Element.new('Parent')
      @child = Element.new('Child')
    end

    it 'takes an element and adds it as a child' do
      expect(@parent.children.size).to eq(0)
      @parent.add_child(@child)
      expect(@parent.children.size).to eq(1)
    end

    it 'takes no element and does not add anything' do
      expect(@parent.children.size).to eq(0)
      @parent.add_child(nil)
      @parent.add_child(String.new '')
      expect(@parent.children.size).to eq(0)
    end
  end

  describe '#add_content_raw(content_lines)' do

    before :each do
      @element = Element.new('String')
    end

    it 'takes a string and adds it to content_raw' do
      content_size_before = @element.content_raw.size
      @element.add_content_raw("New Content Line")
      expect(@element.content_raw.size).to be > content_size_before
    end

    it 'takes no string and does not add anything' do
      content_size_before = @element.content_raw.size
      @element.add_content_raw(nil)
      @element.add_content_raw(Element.new(""))
      expect(@element.content_raw.size).to eq(content_size_before)
    end
  end

  describe '#attributes' do

    it 'returns all class instance variables and instance variables' do
      params = {
        id: 'id',
        type: :type,
        subtype: :subtype,
        line_number: 1,
        content_raw: 'content_raw',
        children: [],
      }
      element = Element.new('Element', params)
      attributes = element.attributes
      expect(attributes.size).to eq(7)
      params.each do |k, v|
        expect(attributes[k]).to eq(v)
      end
    end
  end

  describe 'self#matches?' do

    it 'takes a string and returns true' do
      # always returns true because the regex is //
      result = Element.matches?('Any string')
      expect(result).to eq(true)
    end

    it 'takes no string and returns false' do
      result = Element.matches?(nil)
      result2 = Element.matches?(Element.new(''))
      expect(result).to eq(false)
      expect(result2).to eq(false)
    end
  end

  describe '#as_json' do

    it 'returns attributes-hash' do
      el = Element.new('')
      expect(el.as_json).to be_an_instance_of(Hash)
      expect(el.as_json).to eq(el.attributes)
    end

  end

  describe '#to_json' do

    it 'returns attributes transformed to json-string' do
      el = Element.new('')
      json = el.to_json
      regex = /\{.*"type":"undefined".*\}/
      match = json.match(regex)
      expect(json).to be_an_instance_of(String)
      expect(match).not_to be_nil
    end

  end

  describe '#validate' do

    before :all do
        @elements = [
          Element.new('String', type: :string, content_raw: 'String'),
          Element.new('\n', type: :newline, content_raw: '\n'),
          Element.new('Item', type: :string, content_raw: '\Item')
        ]
        @element = Element.new('Item', type: :string)
    end

    it 'takes a list of elements and returns a valid validation_item' do
      validation_item = @element.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(true)
    end

    it 'takes a list of elements and returns an invalid validation_item' do
      str = 'Does not exist in list'
      el = Element.new(str, type: :string, content_raw: str)
      validation_item = el.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(false)
      expect(validation_item.errors.size).to be > 0
    end

    it 'takes no list of elements and returns an invalid validation_item' do
      validation_item = @element.validate([])
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(false)
      expect(validation_item.errors.size).to be > 0
    end
  end

  describe '#equals?' do

    before :all do
      str1 = 'String'
      str2 = 'Another String'
      @element1 = Element.new(str1, type: :string, content_raw: str1)
      @element2 = Element.new(str2, type: :string, content_raw: str2)
      @element3 = Element.new(str1, type: :string, content_raw: str1)
    end

    it 'takes another element with identic content and returns true' do
      result = @element1.equals?(@element3)
      expect(result).to eq(true)
    end

    it 'takes another element with other content and returns false' do
      result = @element1.equals?(@element2)
      expect(result).to eq(false)
    end

  end

  describe '#to_markup' do
    context 'element is string or newline' do
      it 'returns the string' do
        element = Element.new('string', type: :string)
        markup = element.to_markup
        expect(markup).to eq('string')
      end
    end
  end
end
