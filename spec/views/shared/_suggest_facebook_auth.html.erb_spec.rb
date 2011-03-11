require 'spec_helper'
require 'devise/test_helpers'

describe 'shared/_suggest_facebook_auth.html.erb' do
  
  before(:each) do
    @person = stub_model(Person,
      :facebook_authenticated? => true
    )
    # @view.stub(:resource).and_return(@person)
    # @view.stub(:resource_name).and_return('person')
    # @view.stub(:devise_mapping).and_return(Devise.mappings[:person])
    @view.stub(:current_person).and_return(@person)  
    
    render
  end

  it "should have the 'Connect with Facebook' link" do
    rendered.should have_selector 'a.connectacct-link.facebook-auth', :href => '/people/auth/facebook', :content => 'Connect with Facebook'
  end
  
  it "should have the 'Continue without linking accounts' link" do
    rendered.should have_selector 'a.decline-facebook-auth', :content => 'Continue without linking account'
  end


end
