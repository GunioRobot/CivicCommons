require 'spec_helper'

describe '/authentication/successful_registration.html.erb' do
  
  before(:each) do
    @person = stub_model(Person)
    @view.stub(:current_person).and_return(@person)
    render
  end
  
  it "should have congratulatory remarks" do
    rendered.should contain 'Congratulations! Your registration is complete.'
  end

end
