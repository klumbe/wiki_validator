require 'spec_helper'

describe WikiValidator::Comment do

  before :all do
    @comment_str = "<!-- This is a one-line comment -->"
    @comment_str2 = "<!-- This is a \nmulti-line \tcomment\n-->"
  end

  describe '#new' do
    it 'takes a string and sets type and content_raw' do
      comment = Comment.new(@comment_str)
      expect(comment.type).to eq(:comment)
      expect(comment.content_raw).to eq(' This is a one-line comment ')
    end

    it 'can handle multi-line comments' do
      comment = Comment.new(@comment_str2)
      expect(comment.type).to eq(:comment)
      expect(comment.content_raw).to eq(" This is a \nmulti-line \tcomment\n")
    end
  end

  describe '#to_markup' do
    it 'returns the element as markup-string' do
      comment = Comment.new(@comment_str2)
      markup = comment.to_markup
      STDERR.puts markup
      expect(markup).to be_an_instance_of(String)
      expect(markup).to eq(@comment_str2)
    end
  end
end
