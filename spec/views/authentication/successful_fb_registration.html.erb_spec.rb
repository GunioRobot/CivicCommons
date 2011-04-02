require 'spec_helper'

describe '/authentication/successful_fb_registration.html.erb' do
  
  before(:each) do
    @person = stub_model(Person)
    @view.stub(:current_person).and_return(@person)
    render
  end
  
  it "should render the form with zipcode" do
    rendered.should render_template('/authentication/_update_account_form')
  end

end
