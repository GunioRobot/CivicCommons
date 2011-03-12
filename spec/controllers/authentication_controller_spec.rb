require 'spec_helper'

describe AuthenticationController do
  context "POST decline_fb_auth" do
    def mock_person(stubs={})
      @mock_person ||= mock_model(Person, stubs).as_null_object
    end
    
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
end
