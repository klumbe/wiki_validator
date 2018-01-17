require 'spec_helper'

describe WikiValidator::Link do

  before :all do
    @link_external = "[https://google.com]"
    @link_internal = "[[link_to_page]]"
    @triple = "[[validated_by::Template:Template1]]"
  end

  describe '#new' do
    it 'takes a string and returns a link' do
      link = Link.new("[link]")
      expect(link).to be_an_instance_of(Link)
      expect(link.type).to eq(:link)
      expect(link.content_raw).to eq("link")
    end

    it 'takes a string and returns an internal link' do
      link = Link.new(@link_internal)
      expect(link).to be_an_instance_of(Link)
      expect(link.type).to eq(:link)
      expect(link.subtype).to eq(:internal)
      expect(link.content_raw).to eq("link_to_page")
      expect(link.link).to eq("link_to_page")
      expect(link.triple).to be_nil
    end

    it 'takes a string and returns an external link' do
      link = Link.new(@link_external)
      expect(link).to be_an_instance_of(Link)
      expect(link.type).to eq(:link)
      expect(link.subtype).to eq(:external)
      expect(link.content_raw).to eq("https://google.com")
      expect(link.link).to eq("https://google.com")
      expect(link.triple).to be_nil
    end

    it 'takes a string and returns a triple' do
      link = Link.new(@triple)
      expect(link).to be_an_instance_of(Link)
      expect(link.type).to eq(:link)
      expect(link.subtype).to eq(:triple)
      str = 'validated_by::Template:Template1'
      expect(link.content_raw).to eq(str)
      expect(link.link).to eq(str)
      expect(link.triple).not_to be_nil
      expect(link.triple.size).to be(3)
      expect(link.predicate).to eq('validated_by')
      expect(link.namespace).to eq('Template')
      expect(link.page).to eq('Template1')
      expect(link.object).to eq('Template:Template1')
    end
  end

  describe '#attributes' do

    it 'returns all instance variables' do
      link = Link.new('[[trip::le:abc]]')
      attributes = link.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(13)
      expect(attributes[:link]).to eq('trip::le:abc')
      expect(attributes[:triple]).to be_an_instance_of(Array)
      expect(attributes[:triple].size).to eq(3)
      expect(attributes[:namespace]).to eq('le')
      expect(attributes[:predicate]).to eq('trip')
      expect(attributes[:page]).to eq('abc')
      expect(attributes[:object]).to eq('le:abc')
    end
  end

  describe '#equals?' do

    before :all do
      @link1 = Link.new('[[Link1]]')
      @link2 = Link.new('[Link1]')
      @link3 = Link.new('[[Link3]]')
      @link4 = Link.new('[[trip:let:abc]]')
      @link5 = Link.new('[[Link1]]')
    end

    it 'takes an equal link element and returns true' do
      result = @link1.equals?(@link5)
      expect(result).to eq(true)
    end

    it 'takes no equal link element and returns false' do
      result1 = @link1.equals?(@link2)
      result2 = @link1.equals?(@link3)
      result3 = @link1.equals?(@link4)
      result4 = @link1.equals?(nil)

      expect(result1).to eq(false)
      expect(result2).to eq(false)
      expect(result3).to eq(false)
      expect(result4).to eq(false)
    end
  end

  describe '#validate' do
    before :all do
      @elements = [
        Element.new('string', type: :string),
        Element.new('\n', type: :newline),
        Link.new('[[Link]]'),
        Element.new('string2', type: :string),
        Link.new('[[Trip::let]]'),
      ]
      @element = Link.new('[[Link]]')
      @element2 = Link.new('[[Trip::let]]')
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
      link = Link.new('[[Not_in_list]]')
      validation_item = link.validate(@elements)
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

  describe '#to_markup' do

    context 'is external link' do
      it 'returns an external link' do
        link = Link.new('[external_link]')
        markup = link.to_markup
        expect(markup).to be_an_instance_of(String)
        expect(markup).to eq('[external_link]')
      end
    end

    context 'is internal link or triple' do
      it 'returns an internal link or triple' do
        str_int = '[[internal_link]]'
        str_trip = '[[Trip::let:abc]]'
        link_int = Link.new(str_int)
        link_trip = Link.new(str_trip)
        markup_int = link_int.to_markup
        markup_trip = link_trip.to_markup
        expect(markup_int).to eq(str_int)
        expect(markup_trip).to eq(str_trip)
      end
    end

    context 'Link is created by params' do
      it 'returns the correct string' do
        str_int = 'link_internal'
        str_ext = 'link external'
        str_trip = 'Tri::p:let'
        link_int = Link.new('', subtype: :internal, content_raw: str_int)
        link_ext = Link.new('', subtype: :external, content_raw: str_ext)
        link_trip = Link.new('', subtype: :triple, content_raw: str_trip)
        markup_int = link_int.to_markup
        markup_ext = link_ext.to_markup
        markup_trip = link_trip.to_markup
        expect(markup_int).to eq("[[#{str_int}]]")
        expect(markup_ext).to eq("[#{str_ext}]")
        expect(markup_trip).to eq("[[#{str_trip}]]")
      end

      it 'returns a placeholder if it has been initialized without any string' do
        link_int = Link.new('', subtype: :internal)
        link_ext = Link.new('', subtype: :external)
        link_trip = Link.new('', subtype: :triple)
        markup_int = link_int.to_markup
        markup_ext = link_ext.to_markup
        markup_trip = link_trip.to_markup
        expect(markup_int).to eq('[[<!--Put internal link here-->]]')
        expect(markup_ext).to eq('[<!--Put external link here-->]')
        expect(markup_trip).to eq('[[<!--Put triple link here-->]]')
      end
    end
  end
end
