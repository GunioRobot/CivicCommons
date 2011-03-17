require 'spec_helper'
require 'devise/test_helpers'

describe 'layouts/application.html.erb' do
  def stub_devise
    @person = stub_model(Person,
      :facebook_authenticated? => true
    )
    @view.stub(:facebook_profile_image).and_return('facebook-profile-image-here')
    @view.stub(:current_person).and_return(@person)  
    @view.stub(:resource).and_return(@person)
    @view.stub(:resource_name).and_return('person')
    @view.stub(:devise_mapping).and_return(Devise.mappings[:person])
  end
  before(:each) do
    stub_devise
    stub_template('/shared/_suggest_facebook_auth.js.erb' => 'rendering suggest_facebook_auth.js')
  end
  context 'interstitial modal' do
    it "should be displayed when user is logged in and not declined facebook auth, and have not connected to facebook" do
      @view.stub(:signed_in?).and_return(true)
      @view.stub_chain(:current_person, :declined_fb_auth?).and_return(false)
      @view.stub_chain(:current_person, :facebook_authenticated?).and_return(false)
      render
      rendered.should contain('rendering suggest_facebook_auth.js')
    end
    it "should not be displayed when user is logged in, and declined facebook auth or have connected to facebook " do
      @view.stub(:signed_in?).and_return(true)
      @view.stub_chain(:current_person, :declined_fb_auth?).and_return(true)
      @view.stub_chain(:current_person, :facebook_authenticated?).and_return(true)
      render
      rendered.should_not contain('rendering suggest_facebook_auth.js')
    end
    it "should not be displayed when user is logged in, and declined facebook auth or have connected to facebook " do
      @view.stub(:signed_in?).and_return(true)
      @view.stub_chain(:current_person, :declined_fb_auth?).and_return(true)
      @view.stub_chain(:current_person, :facebook_authenticated?).and_return(true)
      render
      rendered.should_not contain('rendering suggest_facebook_auth.js')
    end
    
    it "should not be displayed when user not logged in" do
      @view.stub(:signed_in?).and_return(false)
      render
      rendered.should_not contain('rendering suggest_facebook_auth.js')
    end
    
    
  end
end
