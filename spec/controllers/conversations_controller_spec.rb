require 'spec_helper'

describe ConversationsController do

  def mock_conversation(stubs={})
    @mock_conversation ||= mock_model(Conversation, stubs).as_null_object
  end

  describe "not logged in" do
    before(:each) do
      @controller.stub(:current_person).and_return(nil)
    end

    {:new => :get, :create => :post}.each do |action, *methods|

      methods.each do |method|
        it "redirects to login for #{method} => :#{action}" do
          send(method, action)
          response.should redirect_to new_person_session_url
        end
      end
    end
  end

  describe "GET index" do

    before(:each) do
      @old_conversation = Factory.create(:conversation, {:created_at => (Time.now - 2.days), :updated_at => (Time.now - 30.seconds), :last_visit_date => Time.now, :recent_visits => 2})
      @new_conversation = Factory.create(:conversation, {:created_at => (Time.now - 1.day), :updated_at => (Time.now - 2.seconds), :last_visit_date => Time.now, :recent_visits => 1})
    end

    it "assigns all conversations as @active, @popular, and @recent" do
      get :index
      assigns(:active).first.should == @new_conversation
      assigns(:active).last.should  == @old_conversation
      assigns(:popular).first.should == @old_conversation
      assigns(:popular).last.should == @new_conversation
      assigns(:recent).first.should == @new_conversation
      assigns(:recent).last.should == @old_conversation
    end

  end

  describe "GET show" do
    before(:each) do
      @person = Factory.create(:registered_user)
      @controller.should_receive(:current_person).at_least(1).and_return(@person)
      @convo = Factory.create(:conversation)
    end

    def do_get
      get :show, :id => @convo.id
    end

    it "assigns the requested conversation as @conversation" do
      do_get
      assigns(:conversation).should == @convo
    end

    it "records a visit to the conversation passing the current user" do
      do_get
      convo = Conversation.find_by_id(@convo.id)
      convo.total_visits.should == @convo.total_visits + 1
      convo.recent_visits.should == @convo.recent_visits + 1
      Visit.where("person_id = #{@person.id} and visitable_id = #{@convo.id}").size.should == 1
    end
  end

  describe "GET new" do
    before(:each) do
      @controller.stub(:current_person).and_return(Factory.build(:normal_person))
      Conversation.stub(:new) { mock_conversation }
      Issue.stub(:alphabetical) { :all_issues }
      get :new, :accept => true
    end

    it "redirects to responsibilities if :accept is not true" do
      get :new, :accept => nil
      response.should redirect_to(conversation_responsibilities_url)
    end

    it "assigns new conversation as @conversation" do
      assigns(:conversation).should be mock_conversation
    end
  end

  describe "POST create" do
    before(:each) do
      @person = Factory.build(:normal_person, :id => 1)
      @controller.stub(:current_person) { @person }
    end

    def do_create
      post :create, :conversation => {}
    end

    describe "with valid params" do
      before(:each) do
        Conversation.stub(:new_user_generated_conversation).with({}, @person) { mock_conversation(:save => true) }
      end

      it "assigns created conversation to @conversation" do
        do_create
        assigns[:conversation].should be mock_conversation
      end

      it "creates conversation with checked issue_ids" do
        Conversation.should_receive(:new_user_generated_conversation).with({'issue_ids' => ["5","10"]}, @person)
        post :create, :conversation => {:issue_ids => ["5", "10"]}
      end

      it "redirects to invite page to Send Invitations" do
        mock_conversation(:id => '35', :save => true)
        do_create
        response.should redirect_to new_invite_url(:source_type => :conversations, :source_id => '35', :conversation_created => true)
      end
    end

    describe "with invalid params" do
      before(:each) do
        Conversation.stub(:new_user_generated_conversation) { mock_conversation(:save => false) }
      end

      it "renders :new template" do
        do_create
        response.should render_template(:new)
      end

      it "populates error messages" do
      end
    end
  end

end
