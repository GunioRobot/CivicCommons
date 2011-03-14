require 'spec_helper'
require 'devise/test_helpers'

describe '/authentication/conflicting_email.html.erb' do
  
  before(:each) do
    @person = stub_model(Person,
      :facebook_authenticated? => true,
      :email => 'johnd@test.com'
    )
    @view.stub(:current_person).and_return(@person)  
    session[:other_email] = 'johnd-newer-email@test.com'
    render
  end
  
  it "should have the current email" do
    rendered.should contain('johnd@test.com')
  end
  
  it "should have the new email suggestion" do
    rendered.should contain('johnd-newer-email@test.com')
  end
  
  it "should have the link to accept" do
    rendered.should have_selector 'a.overwrite-email', :content => 'Yes'
  end
  
  it "should have the link to decline" do
    rendered.should have_selector 'a.cancel-overwrite-email', :content => 'No'
  end


end
