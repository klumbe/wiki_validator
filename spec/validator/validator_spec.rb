require 'spec_helper'

describe WikiValidator::Validator do

  def create_dtos_helper(page_string, template_string)
    page_dto = PageDTO.new('page', 'namespace', page_string)
    page_dto.ast = @parser.parse_content(page_dto.raw_content)
    template_dto = PageDTO.new('template', 'template', template_string)
    template_dto.ast = @parser.parse_constraints(template_dto.raw_content)
    return [page_dto, template_dto]
  end

  before :all do
    @page1 = File.read(File.dirname(__FILE__) +"/input/validator/page1.txt")
    @page_invalid = File.read(File.dirname(__FILE__) +"/input/validator/page_invalid.txt")
    @page_invalid_complex = File.read(File.dirname(__FILE__) +"/input/validator/page_invalid_complex.txt")
    @template_ti = File.read(File.dirname(__FILE__) +"/input/validator/template_ti_simple.txt")
    @template_ti_complex = File.read(File.dirname(__FILE__) +"/input/validator/template_ti_complex.txt")
    @template_el = File.read(File.dirname(__FILE__) +"/input/validator/template_el.txt")
    @template_el_invalid = File.read(File.dirname(__FILE__) +"/input/validator/template_el_invalid.txt")
    @template_mix = File.read(File.dirname(__FILE__) +"/input/validator/template_mix.txt")
    @template_mix_invalid = File.read(File.dirname(__FILE__) +"/input/validator/template_mix_invalid.txt")
    @parser = Parser.new
  end

  describe '#validate' do

    context 'the template only contains TemplateItems' do
      context '(simple)' do
        it 'takes a page and a template and returns a valid ValidationStatus' do
          page_dto, template_dto = create_dtos_helper(@page1, @template_ti)
          val_status = Validator.validate(page_dto, template_dto)
          expect(val_status).to be_an_instance_of(ValidationStatus)
          expect(val_status.valid?).to eq(true)
          expect(val_status.errors.size).to eq(0)
        end

        it 'takes a page and a template and returns an invalid ValidationStatus' do
          page_dto, template_dto = create_dtos_helper(@page_invalid, @template_ti)
          val_status = Validator.validate(page_dto, template_dto)
          expect(val_status).to be_an_instance_of(ValidationStatus)
          expect(val_status.valid?).to eq(false)
          expect(val_status.errors.size).to be > 0
        end
      end

      context '(complex)' do
        it 'takes a page and a template and returns a valid ValidationStatus' do
          page_dto, template_dto = create_dtos_helper(@page1, @template_ti_complex)
          val_status = Validator.validate(page_dto, template_dto)
          expect(val_status).to be_an_instance_of(ValidationStatus)
          expect(val_status.valid?).to eq(true)
          expect(val_status.errors.size).to eq(0)
        end

        it 'takes a page and a template and returns an invalid ValidationStatus' do
          page_dto, template_dto = create_dtos_helper(@page_invalid_complex, @template_ti_complex)
          val_status = Validator.validate(page_dto, template_dto)
          expect(val_status).to be_an_instance_of(ValidationStatus)
          expect(val_status.valid?).to eq(false)
          expect(val_status.errors.size).to be > 0
        end
      end
    end

    context 'the template only contains Elements' do
      it 'takes a page and a template and returns a valid ValidationStatus' do
        page_dto, template_dto = create_dtos_helper(@page1, @template_el)
        val_status = Validator.validate(page_dto, template_dto)
        expect(val_status).to be_an_instance_of(ValidationStatus)
        expect(val_status.valid?).to eq(true)
        expect(val_status.errors.size).to eq(0)
      end

      it 'takes a page and a template and returns an invalid ValidationStatus' do
        page_dto, template_dto = create_dtos_helper(@page1, @template_el_invalid)
        val_status = Validator.validate(page_dto, template_dto)
        expect(val_status).to be_an_instance_of(ValidationStatus)
        expect(val_status.valid?).to eq(false)
        expect(val_status.errors.size).to eq(2)
      end

    end

    context 'the template contains both TemplateItems and other Elements' do
      it 'takes a page and a template and returns a valid ValidationStatus' do
        page_dto, template_dto = create_dtos_helper(@page1, @template_mix)
        val_status = Validator.validate(page_dto, template_dto)
        expect(val_status).to be_an_instance_of(ValidationStatus)
        expect(val_status.valid?).to eq(true)
        expect(val_status.errors.size).to eq(0)
      end

      it 'takes a page and a template and returns an invalid ValidationStatus' do
        page_dto, template_dto = create_dtos_helper(@page1, @template_mix_invalid)
        val_status = Validator.validate(page_dto, template_dto)
        expect(val_status).to be_an_instance_of(ValidationStatus)
        expect(val_status.valid?).to eq(false)
        expect(val_status.errors.size).to eq(1)
        expect(val_status.errors.first.suberrors.size).to eq(3)
      end
    end
  end
end
