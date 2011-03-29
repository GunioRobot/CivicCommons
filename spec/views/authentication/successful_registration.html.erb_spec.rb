require 'spec_helper'

describe '/authentication/successful_registration.html.erb' do
  
  before(:each) do
    @person = stub_model(Person)
    @view.stub(:current_person).and_return(@person)
    render
  end
  
  it "should have the current link to edit the zipcode" do
    rendered.should have_selector 'a', :content => 'zipcode', :href => edit_user_path(@person,:anchor => 'person_zip_code')
  end

end
