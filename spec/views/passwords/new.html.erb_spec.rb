require 'spec_helper'
describe '/passwords/new.html.erb' do
  def stub_person(stubs = {})
    stub_model(Person,
      { :name => 'john doe',
        :bio => 'biohere',
        :zip_code => 1234
      }.merge(stubs)
    )
  end
  
  def colorbox_for(path)
    "$.colorbox({href:'#{path}'"
  end
  
  def content_for(name) 
    view.instance_variable_get(:@_content_for)[name] 
  end
  
  before(:each) do
    @person = stub_person
    view.stub(:resource).and_return(@person)
    view.stub(:resource_name).and_return(:person)
    view.stub(:devise_error_messages!).and_return(true)
  end
  
  it "should display have password form to reset password" do
    render
    content_for(:main_body).should have_selector("form", :action => person_password_path, :method => "post") do |form|
      form.should have_selector("input#person_email")
      form.should have_selector("input#person_submit")
    end    
  end
  it "should not display colorbox" do
    render
    content_for(:main_body).should_not contain colorbox_for(fb_auth_forgot_password_path)
  end
  context "Person has an account that is linked with Facebook" do
    before(:each) do
      @fb_auth_forgot_password = true
    end
    it "should display the modal dialog that has appropriate message" do
      render
      content_for(:main_body).should contain colorbox_for(fb_auth_forgot_password_path)
    end
  end
end
