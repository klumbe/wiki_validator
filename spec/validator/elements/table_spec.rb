require 'spec_helper'

describe WikiValidator::Table do

  before :all do
    @str = "{|\n|-\n|R1 C1\n|R1 C1\n|-\n|R1 C2\n|R2 C2\n|}"
    @str2 = "{|\n|-\n|R1 C1\n|-\n|R1 C2\n|}"
  end

  describe '#new' do

    it 'takes a string and returns a Table element' do
      table = Table.new(@str)
      expect(table).to be_an_instance_of(Table)
      expect(table.type).to equal(:table)
      expect(table.content_raw).to eq(@str[3..-3])
      expect(table.rows).to be_an_instance_of(Array)
      expect(table.rows.size).to eq(2)
    end
  end

  describe '#attributes' do
    it 'returns the correct amount of attributes' do
      table = Table.new(@str)
      attributes = table.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(8)
      expect(attributes[:rows]).to be_an_instance_of(Array)
    end
  end

  describe '#equals?' do

    before :all do
      @table1 = Table.new(@str)
      @table2 = Table.new(@str2)
      @table3 = Table.new(@str)
    end

    it 'takes an equal Table element and returns true' do
      result = @table1.equals?(@table3)
      expect(result).to eq(true)
    end

    it 'takes an inequal Table element and returns false' do
      result = @table1.equals?(@table2)
      result2 = @table1.equals?(nil)
      expect(result).to eq(false)
      expect(result2).to eq(false)
    end
  end

  describe '#validates' do

    before :all do
      @elements = [
        Element.new('string', type: :string),
        Element.new('\n', type: :newline),
        Table.new(@str),
        Element.new('string2', type: :string),
        Table.new(@str2),
      ]
      @element = Table.new(@str)
      @element2 = Table.new(@str2)
    end

    it 'takes a list of elements and returns a valid validation_item' do
      validation_item = @element.validate(@elements)
      validation_item2 = @element2.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(true)
      expect(validation_item2).to be_an_instance_of(ValidationItem)
      expect(validation_item2.valid?).to eq(true)
    end

    it 'takes a list of elements and returns an invalid validation_item' do
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
