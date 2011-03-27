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
      
      def mock_authentication(stubs={})
        @mock_authentication ||= mock_model(Authentication, stubs).as_null_object
      end
      
      def mock_person(stubs={})
        @mock_person ||= mock_model(Person, stubs).as_null_object
      end
      
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
  end

end
