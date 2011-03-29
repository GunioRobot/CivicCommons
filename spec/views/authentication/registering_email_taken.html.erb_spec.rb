require 'spec_helper'
require 'devise/test_helpers'

describe '/authentication/registering_email_taken.html.erb' do
  
  before(:each) do
    flash[:email] = 'johnd@test.com'
    render
  end
  
  it "should have the current email" do
    rendered.should contain('johnd@test.com')
  end

end
