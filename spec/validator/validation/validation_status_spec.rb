require 'spec_helper'

describe WikiValidator::ValidationStatus do

  before :all do
    @page = 'page_name'
    @template = 'template_name'
    @errors = [ValidationError.new(-1, 'msg'), ValidationError.new(-1, 'msg2')]
  end

  describe '#new' do
    it 'takes two parameters and returns a ValidationStatus instance' do
      val_status = ValidationStatus.new(@page, @template)
      expect(val_status).to be_an_instance_of(ValidationStatus)
      expect(val_status.page_name).to eq(@page)
      expect(val_status.template_name).to eq(@template)
      expect(val_status.errors).to be_an_instance_of(Array)
      expect(val_status.errors.size).to eq(0)
    end
  end

  describe '#add_error' do
    it 'takes a ValidationError and adds it to errors list' do
      val_status = ValidationStatus.new(@page, @template)
      expect(val_status.errors.size).to eq(0)
      val_status.add_error(@errors.first)
      expect(val_status.errors.size).to eq(1)
    end
  end

  describe '#add_errors' do
    it 'takes a ValidationError and adds it to errors list' do
      val_status = ValidationStatus.new(@page, @template)
      expect(val_status.errors.size).to eq(0)
      val_status.add_errors(@errors)
      expect(val_status.errors.size).to eq(2)
    end
  end

  describe '#valid?' do
    it 'returns true if ValidationStatus does not contain errors' do
      val_status = ValidationStatus.new(@page, @template)
      expect(val_status.errors.size).to eq(0)
      expect(val_status.valid?).to eq(true)
    end

    it 'returns false if ValidationStatus contains errors' do
      val_status = ValidationStatus.new(@page, @template)
      val_status.add_error(@errors[0])
      expect(val_status.errors.size).to be > 0
      expect(val_status.valid?).to eq(false)
    end
  end
end
