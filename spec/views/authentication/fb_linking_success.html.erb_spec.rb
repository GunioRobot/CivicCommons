require 'spec_helper'
require 'devise/test_helpers'

describe '/authentication/fb_linking_success.html.erb' do
  
  before(:each) do
    @person = stub_model(Person,
      :facebook_authenticated? => true,
      :email => 'johnd@test.com'
    )
    @view.stub(:current_person).and_return(@person)
    render
  end
  
  it "should have the success message" do
    rendered.should contain('Successfully linked your account to Facebook')
  end

end
