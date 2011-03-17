require 'spec_helper'

describe '/issues/contributions/_suggested_action.html.erb' do
  
  def stub_person(stubs={})
    stub_model(Person, stubs)
  end
  
  def stub_contribution(stubs={})
    stub_model(Contribution, stubs)
  end
  
  before(:each) do
    @person = stub_person(:name => 'john doe')
    @contribution = stub_contribution(:person => @person)
    view.stub(:current_person).and_return(@person)
    view.stub(:contribution).and_return(@contribution)
    view.stub_chain(:contribution,:editable_by?).and_return(true)
  end

  it "should display profile image" do
    view.should_receive(:profile_image)
    render
  end

end
