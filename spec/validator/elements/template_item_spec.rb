require 'spec_helper'

describe WikiValidator::TemplateItem do

  before :all do
    @strings = [
      "+string",
      "+section[2]",
      "+section[2,3]",
      "+section{\n}",
      "+section{\n\tattri: bute\n}",
      "+section[?, 5]{\n\tattri: bute\n}",
    ]
  end

  describe '#new' do

    it 'takes a string and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[0])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:string)
      expect(template_item.min).to eq(1)
      expect(template_item.max).to eq(-1)
      expect(template_item.attribs).to be_an_instance_of(Hash)
      expect(template_item.attribs.size).to eq(0)
      expect(template_item.content_raw).to eq('')
    end

    it 'takes a string with amount and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[1])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:section)
      expect(template_item.min).to eq(2)
      expect(template_item.max).to eq(-1)
      expect(template_item.content_raw).to eq('')
    end

    it 'takes a string with min and max and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[2])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:section)
      expect(template_item.min).to eq(2)
      expect(template_item.max).to eq(3)
      expect(template_item.content_raw).to eq('')
    end

    it 'takes a string with body and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[3])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:section)
      expect(template_item.min).to eq(1)
      expect(template_item.max).to eq(-1)
      expect(template_item.content_raw).to eq("")
    end

    it 'takes a string with body and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[4])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:section)
      expect(template_item.min).to eq(1)
      expect(template_item.max).to eq(-1)
      expect(template_item.content_raw).to eq("\tattri: bute\n")
    end

    it 'takes a string with body, min, max and returns a TemplateItem' do
      template_item = TemplateItem.new(@strings[5])
      expect(template_item).to be_an_instance_of(TemplateItem)
      expect(template_item.type).to eq(:section)
      expect(template_item.min).to eq(-1)
      expect(template_item.max).to eq(5)
      expect(template_item.content_raw).to eq("\tattri: bute\n")
    end

    it 'takes a string and params' do
      params1 = {
        attributes: {
          title: 'Test Section',
          min: '3',
          max: '4',
        },
      }
      params2 = {
        attributes: {
          title: 'Test Section',
          amount: '8',
        },
      }
      template_item1 = TemplateItem.new(@strings[0], params1)
      template_item2 = TemplateItem.new(@strings[0], params2)

      expect(template_item1.min).to eq(3)
      expect(template_item1.max).to eq(4)
      expect(template_item1.attribs). to be_an_instance_of(Hash)
      expect(template_item1.attribs.size).to eq(3)
      expect(template_item1.attribs[:title]).to eq('Test Section')

      expect(template_item2.min).to eq(8)
      expect(template_item2.max).to eq(-1)
      expect(template_item2.attribs). to be_an_instance_of(Hash)
      expect(template_item2.attribs.size).to eq(2)
      expect(template_item2.attribs[:title]).to eq('Test Section')
    end

  end

  describe '#attributes' do
    it 'returns the correct amount of attributes' do
      template_item = TemplateItem.new('+section')
      attributes = template_item.attributes
      expect(attributes).to be_an_instance_of(Hash)
      expect(attributes.size).to eq(14)
      expect(attributes[:min]).to eq(1)
      expect(attributes[:max]).to eq(-1)
      expect(attributes[:attribs]).to be_an_instance_of(Hash)
      expect(attributes[:additional_keywords]).to eq(Constants::ADDITIONAL_KEYWORDS)
      expect(attributes[:keywords]).to eq(Constants::KEYWORDS)
      expect(attributes[:collections]).to eq(Constants::COLLECTIONS)
      expect(attributes[:validation_item]).to be_nil
    end
  end

  describe '#validate' do

    before :all do
      @elements = [
        Section.new('= Section 1 =', id: '1'),
        Element.new('String within Section 1', type: :string, id: '1_1'),
        Element.new('\n', type: :newline, id: '1_2'),
        Section.new('= Section 2 =', id: '2'),
        Section.new('== Subsection 2_1 ==', id: '2_1'),
        List.new('# List1', id: '2_1_1'),
        List.new('## List2', id: '2_1_2'),
        Link.new('[[trip::let]]', id: '3'),
      ]
    end

    context 'when it is no collection' do
      context 'and when it is in list' do
        context 'and has no attributes' do
          it 'should return a valid ValidationItem' do
            template_item = TemplateItem.new('+section')
            validation_item = template_item.validate(@elements)
            valid_items = validation_item.valid_elements
            expect(validation_item).to be_an_instance_of(ValidationItem)
            expect(validation_item.valid?).to eq(true)
            expect(valid_items.size).to eq(3)
            expect(valid_items.include?(@elements[4])).to eq(true)
          end
        end

        context 'and has attributes' do
          it 'should return a valid ValidationItem' do
            attributes = {
              attributes: {
                title: 'Subsection 2_1',
              },
            }
            template_item = TemplateItem.new('+section', attributes)
            validation_item = template_item.validate(@elements)
            expect(validation_item).to be_an_instance_of(ValidationItem)
            expect(validation_item.valid?).to eq(true)
          end
        end
      end

      context 'and when it is not in list' do
        context 'and has no attributes' do
          it 'should return an invalid ValidationItem' do
            template_item = TemplateItem.new('+link[4]')
            validation_item = template_item.validate(@elements)
            expect(validation_item).to be_an_instance_of(ValidationItem)
            expect(validation_item.valid?).to eq(false)
          end
        end

        context 'and has attributes' do
          it 'should return an invalid ValidationItem' do
            attributes = {
              attributes: {
                title: 'Test',
              }
            }
            template_item = TemplateItem.new("+section", attributes)
            validation_item = template_item.validate(@elements)
            expect(validation_item).to be_an_instance_of(ValidationItem)
            expect(validation_item.valid?).to eq(false)
          end
        end
      end

      context 'and has min set' do
        it 'takes a list that contains at least min elements of its type' do
          template_item = TemplateItem.new('+section[3]')
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(true)
        end

        it 'takes a list that contains less than min elements of its type' do
          template_item = TemplateItem.new('+section[4]')
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(false)
        end
      end


      context 'and has max set' do
        it 'takes a list that contains max elements of its type' do
          template_item = TemplateItem.new('+section[1,3]')
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(true)
        end

        it 'takes a list that contains more than max elements of its type' do
          template_item = TemplateItem.new('+section[1,2]')
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(false)
        end
      end
    end

    context 'when it is a collection' do

      before :all do
        @children = [
          TemplateItem.new(@strings[0]),
          TemplateItem.new(@strings[1]),
          TemplateItem.new('+tag'),
        ]
        @children2 = [
          TemplateItem.new('+section', attributes: { title: 'Section 1'}),
          TemplateItem.new('+section', attributes: { title: 'Section 2'}),
          TemplateItem.new('+link'),
        ]
        @children3 = [
          @children2[0],
          @children2[2],
        ]

        @elements2 = [
          Section.new('= Section 1 =', id: '1'),
          Section.new('= Section 2 =', id: '2'),
          Link.new('[[trip::let]]', id: '3'),
          Section.new('= Section 1 =', id: '4'),
          Section.new('= Section 2 =', id: '5'),
          Link.new('[[trip::let2]]', id: '6'),
        ]
      end

      context ':any' do

        it 'has at least one child that is in list' do
          template_item = TemplateItem.new('+any', children: @children)
          validation_item = template_item.validate(@elements)
          expect(validation_item.valid?).to eq(true)
        end

        it 'has no child that is in list' do
          childs = [
            TemplateItem.new('+tag'),
            TemplateItem.new('+table'),
            TemplateItem.new('+section', attributes: { title: 'No title' }),
          ]
          template_item = TemplateItem.new('+any', children: childs)
          validation_item = template_item.validate(@elements)
          expect(validation_item.valid?).to eq(false)
        end

      end

      context ':order' do

        context 'when it is not strict' do
          it 'returns true if elements are in the correct order' do
            template_item = TemplateItem.new('+order', children: @children2)
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(true)
          end
        end

        context 'when it is strict' do
          it 'returns true if elements are in strict order' do
            params = {
              attributes: {
                strict: 'true',
              },
              children: @children2,
            }
            template_item = TemplateItem.new('+order', params)
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(true)
          end

          it 'returns false if elements are not in strict order' do
            params = {
              attributes: {
                strict: 'true',
              },
              children: @children3,
            }
            template_item = TemplateItem.new('+order', params)
            validation_item = template_item.validate(@elements)
            expect(validation_item.valid?).to eq(false)
          end
        end

      end

      context 'and has min set' do
        it 'returns true if list contains collection at least min times' do
          template_item = TemplateItem.new('+order[2]', children: @children2)
          validation_item = template_item.validate(@elements2)
          expect(validation_item.valid?).to eq(true)
        end

        it 'returns false if list contains collection less than min times' do
          params = {
            attributes: {
              strict: 'true',
            },
            children: @children2,
          }
          template_item = TemplateItem.new('+order[3]', params)
          validation_item = template_item.validate(@elements2)
          expect(validation_item.valid?).to eq(false)
        end
      end

      context 'and has max set' do

        before :all do
          @params = {
            attributes: {
              strict: 'true',
            },
            children: @children2,
          }
        end

        it 'returns true if list contains collection max times' do
          template_item = TemplateItem.new('+order[1,2]', @params)
          validation_item = template_item.validate(@elements2)
          expect(validation_item.valid?).to eq(true)
        end

        it 'returns false if list contains collection more than max times' do
          template_item = TemplateItem.new('+order[1,1]', @params)
          validation_item = template_item.validate(@elements2)
          expect(validation_item.valid?).to eq(false)
        end

      end
    end

  end

  describe '#to_markup' do
    context 'type is a collection' do
      context 'type is order' do
        it 'returns a markup string containing all child elements and a comment' do
          element = TemplateItem.new('+order[?, 1]')
          element.add_child(TemplateItem.new('+string'))
          element.add_child(TemplateItem.new('+section'))
          element.add_child(TemplateItem.new('+link'))
          markup = element.to_markup
          str = "<!--ORDER must not appear more often than 1 time(s).-->\n"\
                "<!--Every item needs to appear in the correct order.-->\n"\
                "<!--STRING has to exist at least 1 time(s).-->\n"\
                "some_string \n"\
                "<!--/STRING ------->\n\n"\
                "<!--SECTION has to exist at least 1 time(s).-->\n"\
                "<!--Change section level as needed:-->\n"\
                "=<!--Put your section title here.-->=\n\n"\
                "<!--/SECTION ------->\n\n"\
                "<!--LINK has to exist at least 1 time(s).-->\n"\
                "[<!--Put undefined link here-->]\n\n"\
                "<!--/LINK ------->\n\n"\
                "<!--/ORDER ------->"
          expect(markup).to eq(str)
        end
      end

      context 'type is any' do
        it 'returns a markup string containing all child elements and a comment' do
          element = TemplateItem.new('+any[1, ?]')
          element.add_child(TemplateItem.new('+string'))
          element.add_child(TemplateItem.new('+section'))
          element.add_child(TemplateItem.new('+link'))
          markup = element.to_markup
          str = "<!--ANY has to exist at least 1 time(s).-->\n"\
                "<!--Any element can be picket and (within the bounds) exist multiple times.-->\n"\
                "<!--STRING has to exist at least 1 time(s).-->\n"\
                "some_string \n"\
                "<!--/STRING ------->\n\n"\
                "<!--SECTION has to exist at least 1 time(s).-->\n"\
                "<!--Change section level as needed:-->\n"\
                "=<!--Put your section title here.-->=\n\n"\
                "<!--/SECTION ------->\n\n"\
                "<!--LINK has to exist at least 1 time(s).-->\n"\
                "[<!--Put undefined link here-->]\n\n"\
                "<!--/LINK ------->\n\n"\
                "<!--/ANY ------->"
          expect(markup).to eq(str)
        end
      end
    end

    context 'type is an element' do
      it 'returns a markup containing the section and its children with comments' do
        str = "+section[2, 3]"
        element = TemplateItem.new(str)
        element.add_child(TemplateItem.new('+string[5]'))
        markup = element.to_markup
        result = "<!--SECTION has to exist between 2 and 3 times.-->\n"\
                  "<!--Change section level as needed:-->\n"\
                  "=<!--Put your section title here.-->=\n\n"\
                  "<!--STRING has to exist at least 5 time(s).-->\n"\
                  "some_string some_string some_string some_string some_string \n"\
                  "<!--/STRING ------->\n"\
                  "<!--Change section level as needed:-->\n"\
                  "=<!--Put your section title here.-->=\n\n"\
                  "<!--STRING has to exist at least 5 time(s).-->\n"\
                  "some_string some_string some_string some_string some_string \n"\
                  "<!--/STRING ------->\n\n"\
                  "<!--/SECTION ------->"
        expect(markup).to eq(result)
      end
    end
  end
end
