require 'spec_helper'

describe WikiValidator::ValidationError do

  before :all do
    @location = -1
    @template_location = 5
    @message = 'Message string'
  end

  describe '#new' do
    it 'takes three parameters and returns a ValidationError' do
      val_err = ValidationError.new(@location, @template_location, @message)
      expect(val_err).to be_an_instance_of(ValidationError)
      expect(val_err.location).to eq(@location)
      expect(val_err.template_location).to eq(@template_location)
      expect(val_err.message).to eq(@message)
      expect(val_err.suberrors).to be_an_instance_of(Array)
      expect(val_err.suberrors.size).to eq(0)
    end

    it 'takes four parameters and returns a ValidationError with suberrors' do
      suberrors = [ValidationError.new(-1, -1, "")]
      val_err = ValidationError.new(@location, @template_location, @message,  suberrors)
      expect(val_err.suberrors.size).to eq(1)
    end
  end

  describe '#add_suberror' do
    it 'takes another ValidationError and adds it to suberrors' do
      sub_err = ValidationError.new(-1, -1, "")
      val_err = ValidationError.new(@location, @template_location, @message)
      expect(val_err.suberrors.size).to eq(0)
      val_err.add_suberror(sub_err)
      expect(val_err.suberrors.size).to eq(1)
    end
  end
end
