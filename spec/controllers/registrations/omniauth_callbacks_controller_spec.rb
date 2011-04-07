require 'spec_helper'

describe Registrations::OmniauthCallbacksController, "handle facebook authentication callback" do
  
  def response_should_js_redirect_to(path)
    response.should contain "window.opener.location = '#{path}'"
  end
  
  def response_should_js_open_colorbox(path)
    response.should contain "window.opener.$.colorbox({href:'#{path}'"
  end
  
  def stub_successful_auth
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => { "provider" => "facebook", "uid" => "12345", "extra" => { "user_hash" => { "email" => "johnd@test.com" } } }, 
            "omniauth.origin" => conversations_path}
    @controller.stub!(:env).and_return(env)
  end
  
  def stub_failed_auth
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => {}, 
            "omniauth.origin" => conversations_path}
    @controller.stub!(:env).and_return(env)
  end
  
  
  def stub_fb_auth_w_conflicting_email
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => { "provider" => "facebook", "uid" => "12345", "extra" => { "user_hash" => { "email" => "johnd-different-email@test.com" } } } }
    @controller.stub!(:env).and_return(env)
  end
  
  def stub_failed_auth
    # inspired by https://gist.github.com/792715
    # See https://github.com/plataformatec/devise/issues/closed#issue/608
    request.env["devise.mapping"] = Devise.mappings[:person]
    env = { "omniauth.auth" => {} }
    @controller.stub!(:env).and_return(env)
  end
  
  describe "facebook" do
    def mock_authentication(stubs={})
      @mock_authentication ||= mock_model(Authentication, stubs).as_null_object
    end
    
    def mock_person(stubs={})
      @mock_person ||= mock_model(Person, stubs).as_null_object
    end
    
    context "logged in and linking account with facebook" do
      def given_a_registered_user
        @person = Factory.create(:registered_user,:email => 'johnd@test.com')
      end
      
      context "when successfully authenticated to facebook" do
        before(:each) do
          stub_successful_auth
          given_a_registered_user
          sign_in @person
          get :facebook
        end
        
        it "should have linked the account with facebook" do
          @person.facebook_authenticated?.should be_true
        end
        
        it "should display Facebook linking success modal" do
          response_should_js_open_colorbox(fb_linking_success_path)
        end
        
        it "should display the success message" do
          flash[:notice].should == "Successfully linked your accaunt to Facebook"
        end
        
      end
      context "when updating with a conflicting email address" do
        before(:each) do
          stub_fb_auth_w_conflicting_email
          given_a_registered_user
          sign_in @person
          get :facebook
        end
        it "should prompt the user to approve the email update with the new email in facebook or not" do
          response_should_js_open_colorbox(conflicting_email_path)
        end
      end
      context "when failed authenticating to facebook" do
        before(:each) do
          stub_failed_auth
          given_a_registered_user
          sign_in @person
          get :facebook
        end
        
        it "should not have link the account with facebook" do
          @person.facebook_authenticated?.should be_false
        end
        
        it "should redirect to homegape" do
          # response.should redirect_to root_path
          response_should_js_redirect_to(root_path)
        end
        
        it "should display failed to link message" do
          flash[:notice].should == "Could not link your accaunt to Facebook"
        end
        
      end
    end
    context "Not logged in and logging in using facebook" do
            
      def given_a_registered_user_w_facebook_auth
        @person = Factory.create(:registered_user)
        @authentication = Factory.build(:authentication)
        @person.facebook_authentication = @authentication
      end
      
      context "and successfully logging in using facebook" do
        before(:each) do
          stub_successful_auth
          given_a_registered_user_w_facebook_auth
          @controller.stub(:signed_in?).and_return(false)
          Authentication.should_receive(:find_from_auth_hash).and_return(@authentication)
          sign_in @person
          get :facebook
        end
      
        it "should redirect to the previous page" do
          response_should_js_redirect_to(conversations_path)
        end
        
        it "should display successful login using facebook" do  
          flash[:notice].should == 'Successfully authorized from Facebook account.'
        end
        
      end
    end
    context "creating a new account using facebook credentials" do
      context "successfully" do
        before(:each) do
          stub_successful_auth
          @controller.stub(:signed_in?).and_return(false)
          Authentication.should_receive(:find_from_auth_hash).and_return(nil)
          Person.stub(:create_from_auth_hash).and_return(Factory.create(:registered_user))          
          get :facebook
        end

        it "should redirect to the previous page" do
          response_should_js_redirect_to(conversations_path)
        end

        it "should display successful login using facebook" do  
          flash[:notice].should == 'Successfully authorized from Facebook account.'
        end
        
        it "should set the flag to display the successful confirmation modal" do
          flash[:successful_fb_registration_modal].should be_true 
        end
      end

      context "unsuccessfully due to email already existing in the system" do
        before(:each) do
          stub_successful_auth
          @controller.stub(:signed_in?).and_return(false)
          Authentication.should_receive(:find_from_auth_hash).and_return(nil)
          @mock_person = mock_person
          @mock_person.stub(:valid?).and_return(false)
          @mock_person.stub(:errors).and_return({:email => "has already been taken"})
          Person.stub(:create_from_auth_hash).and_return(@mock_person)
          get :facebook
        end

        it "should open a colorbox that tells user to login using facebook instead" do
          response_should_js_open_colorbox(registering_email_taken_path)
        end
        
        it "should NOT set the flag to display the successful confirmation modal" do
          flash[:successful_fb_registration_modal].should_not be_true 
        end
      end
      
      context "unsuccessfuly due to other misc errors" do
        before(:each) do
          stub_successful_auth
          @controller.stub(:signed_in?).and_return(false)
          Authentication.should_receive(:find_from_auth_hash).and_return(nil)
          @mock_person = mock_person
          @mock_person.stub(:valid?).and_return(false)
          Person.stub(:create_from_auth_hash).and_return(@mock_person)
          get :facebook
        end
        
        it "should redirect to back" do
          response_should_js_redirect_to(conversations_path)
        end
        
        it "should display the message 'Something went wrong, your account cannot be created'" do
          response.should contain 'Something went wrong, your account cannot be created'
        end
      end
    end
  end

  describe "miscelaneous failure" do
    before(:each) do
      controller.stub_chain(:failed_strategy,:name).and_return('Facebook')
      I18n.stub(:t).and_return('error message here')
    end
    it "should display the text of the failure" do
      stub_failed_auth
      get :failure
      response.should contain 'error message here'
    end
  end
end
