require 'spec_helper'

describe WikiValidator::Parser do

  before :all do
    @parser = Parser.new
    @input_string = File.read(File.dirname(__FILE__) + "/input/parser_input.txt")
  end

  describe '#parse_content' do
    it 'takes one mandatory parameter and returns a list of elements' do
      elements = @parser.parse_content(@input_string)
      expect(elements).to_not(be_nil)
      expect(elements.empty?).to be(false)
      elements.each do |el|
        expect(el).to be_a(Element)
      end
    end

    it 'takes an additonal parameter and returns sections only' do
      sections = @parser.parse_content(@input_string, return: :sections)
      expect(sections).to_not(be_nil)
      sections.each do |sec|
        expect(sec.type).to eql(:section)
      end
    end

    it 'returns 7 level 1 sections' do
      elements = @parser.parse_content(@input_string)
      secs = elements.select {|el| el.type == :section && el.attributes[:level] == 1}
      expect(secs.size).to eq(7)
    end

    it 'nests elements in sections' do
      elements = @parser.parse_content(@input_string)
      first_section = elements.first
      expect(first_section.type).to eq(:section)
      children = first_section.children
      expect(children.size).to eq(1)
      attributes = children.first.attributes
      expect(attributes[:type]).to eq(:section)
      expect(attributes[:level]).to eq(2)
      expect(attributes[:title]).to eq("Section Level 2")
    end

    it 'returns all given kinds of elements' do
      elements = @parser.parse_content(@input_string)
      num_found = Hash.new(0)
      elements.each do |el|
        num_found[el.type] += 1
      end
      string = num_found[:string]
      new_line = num_found[:newline]
      comment = num_found[:comment]
      link = num_found[:link]
      list = num_found[:list]
      section = num_found[:section]
      table = num_found[:table]
      tag = num_found[:tag]
      template_item = num_found[:template_item]

      # TemplateItem should be recognized as strings, links and so on
      expect(template_item).to eq(0)
      expect(new_line).to eq(0)
      # comment is on the ignore list
      expect(comment).to eq(0)
      # 3 real links and 4 from the parameters of a TemplateItem
      expect(link).to eq(7)
      expect(list).to eq(12)
      expect(section).to eq(12)
      expect(table).to eq(1)
      expect(tag).to eq(3)
    end
  end

  describe '#parse_constraints' do

    before :each do
      @elements = @parser.parse_constraints(@input_string)
    end

    it 'takes one mandatory parameter and returns a list of elements' do
      expect(@elements).to_not(be_nil)
      expect(@elements.empty?).to be(false)
      @elements.each do |el|
        expect(el).to be_a(Element)
      end
    end

    it 'returns correct line_numbers' do
      orders = @elements.select {|el| el.type == :order}
      order = orders.first
      expect(order.line_number).to eq(64)
      children = order.children
      expect(children.size).to eq(2)
      expect(children.first.type).to eq(:section)
      expect(children.first.line_number).to eq(65)
      expect(children.last.line_number).to eq(69)
    end

    it 'takes a string with invalid template_item' do
      ill_file = File.read(File.dirname(__FILE__) + "/input/ill_template_item.txt")
      elements = @parser.parse_constraints(ill_file)
      selected = elements.select {|el| el.type == :section && el.attributes[:title] == 'TestTitle'}
      expect(selected.size).to eq(0)
      child = elements.select {|el| el.type == :child}
      expect(child.size).to eq(1)
      any = elements.select {|el| el.type == :any}
      expect(any.size).to eq(1)
      expect(any.first.children.size).to eq(2)
      expect(elements.size).to eq(10)
    end
  end

end
