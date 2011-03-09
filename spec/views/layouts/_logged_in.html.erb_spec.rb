require 'view_spec_helper'
require 'devise/test_helpers'

describe "layouts/_logged_in.html.erb" do
  
  before(:each) do
    @person = stub_model(Person,
      :facebook_authenticated? => true
    )
    @view.stub(:resource).and_return(@person)
    @view.stub(:resource_name).and_return('person')
    @view.stub(:devise_mapping).and_return(Devise.mappings[:person])
    @view.stub(:current_person).and_return(@person)  
    @view.should_receive(:user_profile).and_return('')
    @view.should_receive(:text_profile).and_return('')
    @view.should_receive(:link_to_settings).and_return('')
    # @view.stub_chain(:user_profile,:html_safe).and_return('')
    # @view.stub_chain(:text_profile,:html_safe).and_return('')
  end

  it "should have logout link" do
    render
    rendered.should contain 'Logout'
    rendered.should have_selector 'a.user-link'
  end
end
