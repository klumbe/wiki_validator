require 'spec_helper'

describe WikiValidator::Section do

  describe '#new' do

    it 'takes a string and returns a Section' do
      section = Section.new('= Section Level 1 =')
      expect(section).to be_an_instance_of(Section)
    end

    it 'takes a string and returns a Section with title and level' do
      section1 = Section.new('= Section Level 1 =')
      section2 = Section.new('== Section Level 2 ==')
      section3 = Section.new('=== Section Level 3 ===')
      section4 = Section.new('==== Section Level 4 ====')
      section5 = Section.new('===== Section Level 5 =====')
      section6 = Section.new('====== Section Level 6 ======')

      expect(section1.level).to eq(1)
      expect(section2.level).to eq(2)
      expect(section3.level).to eq(3)
      expect(section4.level).to eq(4)
      expect(section5.level).to eq(5)
      expect(section6.level).to eq(6)
    end

    it 'takes an invalid string and returns a Section with default values' do
      section = Section.new('No section at all')
      expect(section).to be_an_instance_of(Section)
      expect(section.title).to eq('')
      expect(section.level).to eq(-1)
    end

    it 'takes a string with level being to high and returns highest possible' do
      # in general one should consider to don't treat it as a section at all
      # but this is how it's handled in the wiki
      section = Section.new('======= Too deep =======')
      expect(section).to be_an_instance_of(Section)
      expect(section.title).to eq('= Too deep')
      expect(section.level).to eq(6)
    end

  end

  describe'#attributes' do
    it 'returns the correct amount of attributes' do
      section = Section.new('= Section =')
      attributes = section.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(10)
      expect(attributes[:level]).to eq(1)
      expect(attributes[:title]).to eq('Section')
    end
  end

  describe '#equals?' do

    before :all do
        @section1 = Section.new('= Section =')
        @section2 = Section.new('== Section ==')
        @section3 = Section.new('= Section =')
        @section4 = Section.new('')
    end

    it 'takes a similar element and returns true' do
      result = @section1.equals?(@section3)
      expect(result).to eq(true)
    end

    it 'takes an inequal element and returns false' do
      result1 = @section1.equals?(@section2)
      result2 = @section1.equals?(@section4)
      result3 = @section4.equals?(@section3)

      expect(result1).to eq(false)
      expect(result2).to eq(false)
      expect(result3).to eq(false)
    end
  end

  describe '#to_markup' do
    context 'title and level defined' do
      it 'returns a section string without comments' do
        section = Section.new('=Section1=')
        markup = section.to_markup
        expect(markup).to eq('=Section1=')
      end
    end

    context 'level undefined' do
      it 'returns a section string with comment about level-freedom' do
        section = Section.new('', title: 'Section without level')
        markup = section.to_markup
        expect(markup).to eq("<!--Change section level as needed:-->\n=Section without level=")
      end
    end

    context 'title undefined' do
      it 'returns a section string with comment for the title' do
        section = Section.new('', level: 2)
        markup = section.to_markup
        expect(markup).to eq('==<!--Put your section title here.-->==')
      end
    end
  end

  describe '#validate' do
    before :all do
      @elements = [
        Element.new('string', type: :string),
        Element.new('\n', type: :newline),
        Section.new('== Section 1 =='),
        Element.new('string2', type: :string),
        Section.new('= Section 2 ='),
      ]
      @element = Section.new('== Section 1 ==')
      @element2 = Section.new('= Section 2 =')
    end
    it 'takes a section of elements and returns a valid validation_item' do
      validation_item = @element.validate(@elements)
      validation_item2 = @element2.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(true)
      expect(validation_item2).to be_an_instance_of(ValidationItem)
      expect(validation_item2.valid?).to eq(true)
    end

    it 'takes a section of elements and returns an invalid validation_item' do
      section = Section.new('== Not_in_list ==')
      validation_item = section.validate(@elements)
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(false)
      expect(validation_item.errors.size).to be > 0
    end

    it 'takes no section of elements and returns an invalid validation_item' do
      validation_item = @element.validate([])
      expect(validation_item).to be_an_instance_of(ValidationItem)
      expect(validation_item.valid?).to eq(false)
      expect(validation_item.errors.size).to be > 0
    end
  end
end
