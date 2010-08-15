require 'spec_helper'

describe Question do
  describe "when creating a question for a conversation" do
    before(:each) do
      @mock_person = Factory.create(:normal_person)      
    end
    context "and the conversation id is not correct" do
      it "should return a question with an error" do
        Conversation.stub(:find).with(999).and_return(nil)
        question = Question.create_for_conversation({:datetime=>Time.now, :owner=>1, :content=>"Hello World"}, 999, @mock_person)
        question.errors[:parent_id].nil?.should == false
        question.errors[:parent_id].blank?.should == false  
      end
    end
    context "and there is a validation error with the comment" do
      it "should return a comment with an error" do
        Conversation.stub(:find).with(999).and_return(nil)
        question = Question.create_for_conversation({:datetime=>Time.now, :owner=>1, :content=>nil}, 999, @mock_person)
        question.errors.count.should_not == 0
      end
    end
    context "and the comment saves successfully" do
      it "should add the comment to a conversation" do
        conversation = Factory.create(:conversation)
        Conversation.stub(:find).with(1).and_return(conversation)
        question = Question.create_for_conversation({:datetime=>Time.now, :owner=>1, :content=>"Hello World"}, 1, @mock_person)
        conversation.posts.count.should == 1
        conversation.posts[0].postable.should == question
      end
      it "should return a comment with no errors" do
        conversation = Factory.create(:conversation)
        Conversation.stub(:find).with(1).and_return(conversation)
        question = Question.create_for_conversation({:datetime=>Time.now, :owner=>1, :content=>"Hello World"}, 1, @mock_person)
        question.errors.count.should == 0
      end  
      it "should set the passed in user as the owner" do
        conversation = Factory.create(:conversation)
        Conversation.stub(:find).with(1).and_return(conversation)
        question = Question.create_for_conversation({:datetime=>Time.now, :owner=>1, :content=>"Hello World"}, 1, @mock_person)
        question.person.should == @mock_person
      end    
    end
  end
  
end
