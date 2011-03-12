require "spec_helper"

describe AuthenticationController do

  describe "routing" do
    it "recognizes and generates #decline_fb_auth" do
      { post: "/authentication/decline_fb_auth" }.should route_to(controller: "authentication", action: "decline_fb_auth")
    end
  end

end
