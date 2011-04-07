require 'spec_helper'
describe '/passwords/edit.html.erb' do
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
  
  before(:each) do
    @person = stub_person
    view.stub(:resource).and_return(@person)
    view.stub(:resource_name).and_return(:person)
    view.stub(:devise_error_messages!).and_return(true)
  end
  
  it "should display have password form to reset password" do
    render
    content_for(:main_body).should have_selector("form", :action => person_password_path, :method => "post") do |form|
      form.should have_selector("input#person_reset_password_token")
      form.should have_selector("input#person_password")
      form.should have_selector("input#person_password_confirmation")
      form.should have_selector("input#person_submit")
    end    
  end
end
