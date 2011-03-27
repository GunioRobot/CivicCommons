require 'spec_helper'
require 'devise/test_helpers'

describe SessionsController do
  
  def mock_person(stubs={})
    @mock_person ||= mock_model(Person, stubs).as_null_object
  end

  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:person]
  end
  
  context "POST create" do
    
    context "redirection after signing in" do
      
      before(:each) do
        @person = Factory.create(:registered_user)
        warden.stub(:authenticate!).and_return(@person)
      end
      
      it "should redirect to the previous page, if there was a previous page" do
        session[:previous] = 'http://test.host/conversations'
        
        post :create
        response.should redirect_to 'http://test.host/conversations'
      end

      it "should redirect to root_url if previous page is 'people/login'" do
        session[:previous] = 'http://test.host/people/login'
        
        post :create
        response.should redirect_to 'http://test.host/'
      end

      it "should redirect to root_url if previous page is 'register/new'" do
        session[:previous] = 'http://test.host/people/register/new'
        
        post :create
        response.should redirect_to 'http://test.host/'
      end

      it "should redirect to root_url by default" do
        post :create
        response.should redirect_to 'http://test.host/'
      end

    end
    
  end
  
end
