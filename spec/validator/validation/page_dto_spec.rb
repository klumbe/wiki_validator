require 'spec_helper'

describe WikiValidator::PageDTO do

  before :all do
      @name = 'page_name'
      @namespace = 'page_namespace'
      @content_string = 'content string'
  end

  describe '#new' do
    it 'takes three parameters and returns a PageDTO' do
      page_dto = PageDTO.new(@name, @namespace, @content_string)
      expect(page_dto).to be_an_instance_of(PageDTO)
      expect(page_dto.name).to eq(@name )
      expect(page_dto.namespace).to eq(@namespace)
      expect(page_dto.content_string).to eq(@content_string)
      expect(page_dto.ast).to be_an_instance_of(Array)
      expect(page_dto.ast.size).to eq(0)
    end
  end

  describe '#attributes' do
    it 'returns all instance variables' do
      page_dto = PageDTO.new(@name, @namespace, @content_string)
      attributes = page_dto.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(4)
      expect(attributes[:name]).to eq(@name)
      expect(attributes[:namespace]).to eq(@namespace)
      expect(attributes[:content_string]).to eq(@content_string)
      expect(attributes[:ast]).to be_an_instance_of(Array)
      expect(attributes[:ast].size).to eq(0)
    end
  end
end
