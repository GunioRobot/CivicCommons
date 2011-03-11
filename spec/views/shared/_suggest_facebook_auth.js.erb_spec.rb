require 'spec_helper'

describe 'shared/_suggest_facebook_auth.js.erb' do
  
  before(:each) do
    render
  end

  it "should render the suggest facebook content partial" do
    rendered.should render_template('/shared/_suggest_facebook_auth')
  end


end
