require 'spec_helper'

describe WikiValidator::List do

  describe '#new' do

    it 'takes a string and returns a list' do
      list = List.new('#List-Item')
      expect(list).to be_an_instance_of(List)
      expect(list.type).to eq(:list)
      expect(list.content_raw).to eq('List-Item')
    end

    it 'takes a string and returns a list of subtype :enumeration' do
      list = List.new('#List-Item')
      expect(list).to be_an_instance_of(List)
      expect(list.type).to eq(:list)
      expect(list.subtype).to eq(:enumeration)
      expect(list.content_raw).to eq('List-Item')
    end

    it 'takes a string and returns a list of subtype :bullet' do
      list = List.new('*List-Item')
      expect(list).to be_an_instance_of(List)
      expect(list.type).to eq(:list)
      expect(list.subtype).to eq(:bullet)
      expect(list.content_raw).to eq('List-Item')
    end

    it 'takes a string and returns a list of subtype :indent' do
      list = List.new(':List-Item')
      expect(list).to be_an_instance_of(List)
      expect(list.type).to eq(:list)
      expect(list.subtype).to eq(:indent)
      expect(list.content_raw).to eq('List-Item')
    end
    it 'takes a string and returns a list of subtype :definition' do
      list = List.new(';List-Item')
      expect(list).to be_an_instance_of(List)
      expect(list.type).to eq(:list)
      expect(list.subtype).to eq(:definition)
      expect(list.content_raw).to eq('List-Item')
    end

    it 'takes a string and returns a list with correct level' do
      list = List.new('*List-Item')
      list2 = List.new('##List-Item Level 2')
      list3 = List.new(':::List-Item Level 3')
      expect(list).to be_an_instance_of(List)
      expect(list.level).to eq(1)
      expect(list2).to be_an_instance_of(List)
      expect(list2.level).to eq(2)
      expect(list3).to be_an_instance_of(List)
      expect(list3.level).to eq(3)
    end

  end

  describe '#attributes' do
    it 'returns the correct amount of attributes' do
      list = List.new('#List-Item')
      attributes = list.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(8)
      expect(attributes[:level]).to eq(1)
    end
  end

  describe '#equals?' do
    before :all do
      @list1 = List.new('#list1')
      @list2 = List.new(':list1')
      @list3 = List.new('#list3')
      @list4 = List.new('*list1')
      @list5 = List.new('#list1')
      @list6 = List.new(';list1')
    end

    it 'takes an equal list element and returns true' do
      result = @list1.equals?(@list5)
      expect(result).to eq(true)
    end

    it 'takes no equal list element and returns false' do
      result1 = @list1.equals?(@list2)
      result2 = @list1.equals?(@list3)
      result3 = @list1.equals?(@list4)
      result4 = @list1.equals?(nil)
      result5 = @list1.equals?(@list6)

      expect(result1).to eq(false)
      expect(result2).to eq(false)
      expect(result3).to eq(false)
      expect(result4).to eq(false)
      expect(result5).to eq(false)
    end
  end

  describe '#to_markup' do
    context 'has a specific subtype' do
      it 'is of and returns a enumeration' do
        str = '# list item'
        list = List.new(str)
        markup = list.to_markup()
        expect(markup).to eq(str)
      end
    end

    context 'subtype and content_raw not set' do
      it 'returns a bullet item' do
        list = List.new('')
        markup = list.to_markup()
        expect(markup).to eq('*<!--Put your list string here.-->')
      end
    end
  end

  describe '#validate' do
    before :all do
      @elements = [
        Element.new('string', type: :string),
        Element.new('\n', type: :newline),
        List.new('* Bullet'),
        Element.new('string2', type: :string),
        List.new('# Enumeration'),
      ]
      @element = List.new('* Bullet')
      @element2 = List.new('# Enumeration')
    end

    it 'takes a list of elements and returns a valid validation_item' do
      validation_item = @element.validate(@elements)
      validation_item2 = @element2.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(true)
      expect(validation_item2).to be_an_instance_of(ValidationItem)
      expect(validation_item2.valid?).to eq(true)
    end

    it 'is no list and takes a list of elements and returns an invalid validation_item' do
      list = List.new('[[Not_in_list]]')
      validation_item = list.validate(@elements)
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
end
