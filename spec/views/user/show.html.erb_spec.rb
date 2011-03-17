require 'spec_helper'

describe 'user/show.html.erb' do
  def stubs
    @user = stub_model(Person,
      :facebook_authenticated? => true,
      :name => 'john doe',
      :bio => 'biohere'
    )
    @contribution = stub_model(Contribution)
    @contributions = []
    @issue_subscription = stub_model(Subscription)
    @issue_subscriptions = []
    @conversation_subscription = stub_model(Subscription)
    @conversation_subscriptions = []
  end
  
  it "should display profile image" do
    stubs
    view.should_receive(:profile_image)
    render
  end

end
