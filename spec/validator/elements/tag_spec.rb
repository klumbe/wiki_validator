require 'spec_helper'

describe WikiValidator::Tag do

  before :all do
    @strings = [
      "<empty_tag></empty_tag>",
      "<empty_tag2 />",
      "<tag3>Content</tag3>",
      "<tag4 attr='value'>Content2</tag4>",
    ]
  end

  describe '#new' do

    it 'takes a string and returns a Tag element' do
      tag = Tag.new(@strings[0])
      tag2 = Tag.new(@strings[3])
      expect(tag).to be_an_instance_of(Tag)
      expect(tag.type).to eq(:tag)
      expect(tag.tag).to eq('empty_tag')
      expect(tag.subtype).to eq(:empty_tag)
      expect(tag.attribs).to be_an_instance_of(Array)
      expect(tag.attribs.size).to eq(0)

      expect(tag2).to be_an_instance_of(Tag)
      expect(tag2.attribs.size).to eq(1)
      expect(tag2.attribs.first).to eq("attr='value'")
    end

  end

  describe '#attributes' do
    it 'returns the correct amount of attributes' do
      tag = Tag.new(@strings[3])
      attributes = tag.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(9)
      expect(attributes[:tag]).to eq('tag4')
      expect(attributes[:subtype]).to eq(:tag4)
      expect(attributes[:attribs].size).to eq(1)
      expect(attributes[:attribs].include?("attr='value'")).to eq(true)
    end
  end

  describe '#equals?' do
    before :all do
      @tag1 = Tag.new(@strings[0])
      @tag2 = Tag.new(@strings[1])
      @tag3 = Tag.new(@strings[2])
      @tag4 = Tag.new(@strings[3])
      @tag5 = Tag.new(@strings[0])
    end

    it 'takes an equal tag element and returns true' do
      result = @tag1.equals?(@tag5)
      expect(result).to eq(true)
    end

    it 'takes no equal tag element and returns false' do
      result1 = @tag1.equals?(@tag2)
      result2 = @tag1.equals?(@tag3)
      result3 = @tag1.equals?(@tag4)
      result4 = @tag1.equals?(nil)

      expect(result1).to eq(false)
      expect(result2).to eq(false)
      expect(result3).to eq(false)
      expect(result4).to eq(false)
    end
  end

  describe '#validate' do
    before :all do
      @elements = [
        Section.new('== Section 1 =='),
        Element.new('string', type: :string),
        Element.new('\n', type: :newline),
        Tag.new(@strings[0]),
        List.new('* Bullet'),
        Element.new('string2', type: :string),
        Tag.new(@strings[3]),
        List.new('# Enumeration'),
      ]
      @element = Tag.new(@strings[0])
      @element2 = Tag.new(@strings[3])
      @element3 = Tag.new(@strings[2])
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
      validation_item = @element3.validate(@elements)
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
