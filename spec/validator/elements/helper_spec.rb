require 'spec_helper'

describe WikiValidator::Helper do

    describe 'self#find_element_class' do
      it 'takes a template_item of type comment and returns nil' do
        # Comment is ignored and can't be checked then -> can be added anytime
        ti = TemplateItem.new('+comment')
        clss = Helper.find_element_class(ti)
        expect(clss).to be_nil
      end

      it 'takes a TemplateItem of type string Element' do
        ti = TemplateItem.new('+string')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Element)
      end

      it 'takes a TemplateItem of type newline and returns Element' do
        ti = TemplateItem.new('+newline')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Element)
      end

      it 'takes a TemplateItem of type link and returns Link' do
        ti = TemplateItem.new('+link')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Link)
      end

      it 'takes a TemplateItem of type list and returns List' do
        ti = TemplateItem.new('+list')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(List)
      end

      it 'takes a TemplateItem of type section and returns Section' do
        ti = TemplateItem.new('+section')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Section)
      end

      it 'takes a TemplateItem of type table and returns Table' do
        ti = TemplateItem.new('+table')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Table)
      end

      it 'takes a TemplateItem of type tag and returns Tag' do
        ti = TemplateItem.new('+tag')
        clss = Helper.find_element_class(ti)
        expect(clss).to eq(Tag)
      end

    end

    describe 'self#create_comment' do

      context 'no lower bound set' do
        context 'no upper bound set' do
          it 'returns a comment stating that it can appear as often as one likes' do
            str = Helper.create_comment(:type, -1, -1)
            expect(str).to eq('<!--TYPE is optional and can appear as often as one likes.-->')
          end
        end

        context 'upper bound set' do
          it 'returns a comment stating that it must not exist more than the bound' do
            str = Helper.create_comment(:type, -1, 5)
            expect(str).to eq('<!--TYPE must not appear more often than 5 time(s).-->')
          end
        end
      end

      context 'lower bound set' do
        context 'no upper bound set' do
          it 'returns a comment stating that it have to exist at least max times' do
            str = Helper.create_comment(:type, 3, -1)
            expect(str).to eq('<!--TYPE has to exist at least 3 time(s).-->')
          end
        end

        context 'upper bound set' do
          it 'returns a comment stating that it has upper and lower bounds' do
            str = Helper.create_comment(:type, 2, 5)
            expect(str).to eq('<!--TYPE has to exist between 2 and 5 times.-->')
          end
        end

        context 'upper bound equals lower bound' do
          it 'returns a comment stating that it has to exist exactly x times' do
            str = Helper.create_comment(:type, 4, 4)
            expect(str).to eq('<!--TYPE has to exist exactly 4 time(s).-->')
          end
        end
      end

    end

end
