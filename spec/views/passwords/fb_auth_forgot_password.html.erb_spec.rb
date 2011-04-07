require 'spec_helper'
describe '/passwords/fb_auth_forgot_password.html.erb' do

  before(:each) do
    render
  end
  
  it "should display sign up with facebook link" do
    render
    rendered.should have_selector "a.fb-login-btn"
  end
end
