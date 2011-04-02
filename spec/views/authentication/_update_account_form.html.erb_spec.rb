require 'spec_helper'

describe '/authentication/successful_fb_registration.html.erb' do
  
  before(:each) do
    @person = stub_model(Person)
    @view.stub(:current_person).and_return(@person)
    render
  end
  
  it "should render the form with zipcode" do
    rendered.should have_selector("form", :action => auth_update_account_path, :method => "post") do |form|
      form.should have_selector("input#person_zip_code", :name => "person[zip_code]")
      form.should have_selector("input#person_submit")
      form.should have_selector("a.cancel")
    end    
  end

end
