require 'spec_helper'
describe '/user/edit.html.erb' do
  def stub_person(stubs = {})
    stub_model(Person,
      { :name => 'john doe',
        :bio => 'biohere',
        :zip_code => 1234
      }.merge(stubs)
    )
  end
  
  def content_for(name) 
    view.instance_variable_get(:@_content_for)[name] 
  end

  def given_a_person_with_facebook_authentication
    @person = stub_person(:facebook_authenticated? => true)
    view.stub(:current_person).and_return(@person)
  end
  
  def given_a_person_without_facebook_authentication
    @person = stub_person(:facebook_authenticated? => false)
    view.stub(:current_person).and_return(@person)
  end
  
  context "profile picture" do
    
    it "should display profile image" do
      given_a_person_with_facebook_authentication
      view.should_receive(:profile_image)
      render
    end
    
    it "should display 'Remove Picture' if  the user has an avatar" do
      @person = stub_person(:avatar? => true)
      view.stub(:current_person).and_return(@person)
      render
      content_for(:main_body).should contain "Remove Picture"
    end
    
    it "should not display 'Remove Picture if user has no avatar " do
      @person = stub_person(:avatar? => false)
      view.stub(:current_person).and_return(@person)
      render
      content_for(:main_body).should_not contain "Remove Picture"      
    end
  end
  
  context "Link to Facebook" do
    
    before(:each) do
      view.stub(:profile_image).and_return('')
    end
    
    it "should display 'Connect with facebook' button if the user is not authenticated with Facebook" do
      given_a_person_without_facebook_authentication
      render
      content_for(:main_body).should have_selector 'a.connectacct-link.facebook-auth', :content => "Connect with Facebook"
    end
    
    it "should display 'unlink facebook' button if the user has linked the account with Facebook" do
      given_a_person_with_facebook_authentication
      render
      content_for(:main_body).should have_selector 'a.connectacct-link.facebook-auth.disconnect-fb', :content => "Unlink Account"
    end
    
  end

end
