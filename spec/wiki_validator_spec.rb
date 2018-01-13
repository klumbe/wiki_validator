require "spec_helper"

RSpec.describe WikiValidator do
  it "has a version number" do
    expect(WikiValidator::VERSION).not_to be nil
  end

  describe WikiValidator::WikiValidator do

    before(:each) do
      @wiki_validator = WikiValidator::WikiValidator.new
    end

    describe '#new' do
      it 'sets initial values and returns a new WikiValidator' do
        params = {parser: {sectioning: true}}
        wiki_validator = WikiValidator::WikiValidator.new(params)
        expect(wiki_validator).to be_an_instance_of(WikiValidator::WikiValidator)
        expect(wiki_validator.page).to be_nil
        expect(wiki_validator.templates).to be_an_instance_of(Array)
        expect(wiki_validator.templates.size).to eq(0)
      end
    end

    describe '#set_page' do
      it 'takes a PageDTO, parses string and sets it as instance variable' do
        page_dto = PageDTO.new('page_name', 'page_namespace', 'content string')
        expect(@wiki_validator.page).to be_nil
        @wiki_validator.set_page(page_dto)
        expect(@wiki_validator.page).to be_an_instance_of(PageDTO)
        expect(@wiki_validator.page.ast.size).to be > 0
      end

      it 'does nothing if no PageDTO is provided' do
        expect(@wiki_validator.page).to be_nil
        @wiki_validator.set_page([])
        expect(@wiki_validator.page).to be_nil
      end
    end

    describe '#parse_page' do
      it 'takes a PageDTO and sets its ast' do
        str = "= Heading ="
        page_dto = PageDTO.new('name', 'namespace', str)
        expect(page_dto.ast.size).to eq(0)
        result = @wiki_validator.parse_page(page_dto)
        expect(result).to equal(page_dto)
        expect(result.ast.size).to eq(1)
        expect(result.ast.first).to be_an_instance_of(Section)
      end
    end

    describe '#add_template' do
      it 'takes a PageDTO, parses string and adds it to templates' do
        template_dto = PageDTO.new('template_name', 'template_namespace', '+section')
        expect(@wiki_validator.templates.size).to eq(0)
        @wiki_validator.add_template(template_dto)
        expect(@wiki_validator.templates.size).to eq(1)
        expect(@wiki_validator.templates.first).to equal(template_dto)
      end

      it 'does nothing if no PageDTO is provided' do
        expect(@wiki_validator.templates.size).to eq(0)
        @wiki_validator.add_template([])
        expect(@wiki_validator.templates.size).to eq(0)
      end
    end

    describe '#add_templates' do
      it 'takes a list of templates and adds them' do
        list = [PageDTO.new("1", "", ""),
                PageDTO.new("2", "", ""),
                PageDTO.new("3", "", ""),
              ]
        expect(@wiki_validator.templates.size).to eq(0)
        @wiki_validator.add_templates(list)
        expect(@wiki_validator.templates.size).to eq(3)
      end
    end

    describe '#parse_template' do
      # more test cases can be found in the Parsers class

      it 'takes a PageDTO and sets its ast' do
        str = "+order{\n\t+section\n}"
        template_dto = PageDTO.new('name', 'namespace', str)
        expect(template_dto.ast.size).to eq(0)
        result = @wiki_validator.parse_template(template_dto)
        expect(result).to equal(template_dto)
        expect(result.ast.size).to eq(1)
        first = result.ast.first
        expect(first).to be_an_instance_of(TemplateItem)
        expect(first.children.size).to eq(1)
        expect(first.children.first.type).to eq(:section)
      end
    end

    describe '#extract_template_names' do
      it 'takes a page with templates and returns just the names of the templates' do
        str = "# abc\n"\
              "== Metadata ==\n"\
              "# [[Other::Triplet]]\n"\
              "# [[validatedBy::Validation:Template1]]\n"\
              "# [[validatedby::Validation:Template2]]"
        page_dto = PageDTO.new('name', 'namespace', str)
        @wiki_validator.set_page(page_dto)
        expect(page_dto.ast.size).to be > 0
        templates = @wiki_validator.extract_template_names()

        expect(templates).to be_an_instance_of(Array)
        expect(templates.size).to eq(2)
        expect(templates.include?('Validation:Template1')).to eq(true)
        expect(templates.include?('Validation:Template2')).to eq(true)
      end
    end

    describe '#generate_page' do
      it 'takes a template, a page and returns a new PageDTO with markup' do
        template_file = File.read(File.dirname(__FILE__) + "/input/template_mix.txt")
        template_markup_file = File.read(File.dirname(__FILE__) + "/input/template_mix_markup.txt")
        template_dto = PageDTO.new('template', 'namespace', template_file)
        page_dto = PageDTO.new('page', 'namespace', '')
        new_page_dto = @wiki_validator.generate_page(template_dto, page_dto)
        expect(new_page_dto.name).to eq(page_dto.name)
        expect(new_page_dto.namespace).to eq(page_dto.namespace)
        expect(new_page_dto.content_string).to eq(template_markup_file)
      end
    end

    describe '#validate' do

      before :each do
        file = File.read(File.dirname(__FILE__) + "/input/validator_template.txt")
        @template = PageDTO.new('Contribution', 'Validation', file)
      end

      context 'valid page' do
        it 'returns one valid ValidationStatus' do
          file = File.read(File.dirname(__FILE__) + "/input/validator_page_valid.txt")
          page = PageDTO.new('Nice', 'Contribution', file)
          @wiki_validator.set_page(page)
          template_names = @wiki_validator.extract_template_names()
          expect(template_names.size).to eq(1)
          expect(template_names.first).to eq('Validation:Contribution')
          @wiki_validator.add_template(@template)

          results = @wiki_validator.validate()
          expect(results.size).to eq(1)
          status = results.first
          expect(status).to be_an_instance_of(ValidationStatus)
          expect(status.valid?).to eq(true)
        end

      end

      context 'invalid page' do
        it 'returns one invald ValidationStatus' do
          file = File.read(File.dirname(__FILE__) + "/input/validator_page_invalid.txt")
          page = PageDTO.new('Bad', 'Contribution', file)
          @wiki_validator.set_page(page)
          template_names = @wiki_validator.extract_template_names()
          expect(template_names.size).to eq(1)
          expect(template_names.first).to eq('Validation:Contribution')
          @wiki_validator.add_template(@template)

          results = @wiki_validator.validate()
          expect(results.size).to eq(1)
          status = results.first
          expect(status).to be_an_instance_of(ValidationStatus)
          expect(status.valid?).to eq(false)
          expect(status.errors.size).to eq(1)
        end
      end

    end
  end
end
