require 'spec_helper'

describe AuthenticationController do
  def mock_person(stubs={})
    @mock_person ||= mock_model(Person, stubs).as_null_object
  end
  
  context "POST decline_fb_auth" do
    
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should set declined_fb_auth to true" do
      @person.should_receive(:update_attribute).with(:declined_fb_auth, true).and_return(true)
      post :decline_fb_auth
      response.should be_ok
    end
    
    it "should return different status if unable to set declined_fb_auth to true" do
      @person.should_receive(:update_attribute).with(:declined_fb_auth, true).and_return(false)
      @controller.stub_chain(:current_person,:errors,:full_messages).and_return('error messages here')
      post :decline_fb_auth
      response.body.should contain('error messages here')
      response.status.should == 422
    end
    
  end
  
  context "GET conflicting_email" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should render no layout" do
      get :conflicting_email
      response.should render_template(:layout => false)
    end
  end

  context "PUT update_conflicting_email" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should update current person's email if session[:other_email] is not blank" do
      session[:other_email] = 'johnd@test.com'
      @person.should_receive(:update_attribute).with(:email, 'johnd@test.com').and_return(true)
      put :update_conflicting_email
      response.should be_ok
    end
    
    it "should clear the session[:other_email]" do
      session[:other_email] = 'johnd@test.com'
      put :update_conflicting_email
      session[:other_email].should be_nil
    end
    
    it "should not update current person's email if session[:other_email] is blank" do
      @person.should_not_receive(:update_attribute)
      put :update_conflicting_email
      response.status.should == 422
    end
  end

  context "GET registering_email_taken" do
    it "should render no layout" do
      get :registering_email_taken
      response.should render_template(:layout => false)
    end
  end

  context "GET conflicting_email" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should render no layout" do
      get :conflicting_email
      response.should render_template(:layout => false)
    end
  end
  
  context "GET successful_registration" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should render no layout" do
      get :successful_registration
      response.should render_template(:layout => false)
    end
  end
  
  context "GET successful_fb_registration" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should render no layout" do
      get :successful_fb_registration
      response.should render_template(:layout => false)
    end
  end
  
  context "GET fb_linking_success" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
    
    it "should render no layout" do
      get :fb_linking_success
      response.should render_template(:layout => false)
    end
  end
  
  context "PUT update_account" do
    before(:each) do
      @person = mock_person
      @controller.stub(:current_person).and_return(@person)
    end
        
    it "should render colorbox for confirmation if successful" do
      @person.should_receive(:update_attributes).with(hash_including(:zip_code => 1234)).and_return(true)
      put :update_account, :person => {:zip_code => 1234}
      response.should be_ok
      response.body.should contain "$.colorbox({href:'/authentication/successful_registration'})"
    end
    
    it "should render the form if unsuccessful" do
      @person.should_receive(:update_attributes).and_return(false)
      put :update_account, :person => {:zip_code => 1234}
      response.should be_ok
      response.body.should render_template 'authentication/_update_account_form'
    end
  end
  
end
