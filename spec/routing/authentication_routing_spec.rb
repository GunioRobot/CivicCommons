require "spec_helper"

describe AuthenticationController do

  describe "routing" do
    it "recognizes and generates #decline_fb_auth" do
      { post: "/authentication/decline_fb_auth" }.should route_to(controller: "authentication", action: "decline_fb_auth")
    end
    
    it "recognizes and generates GET #conflicting_email" do
      { get: "/authentication/conflicting_email" }.should route_to(controller: "authentication", action: "conflicting_email")
    end

    it "recognizes and generates POST #conflicting_email" do
      { post: "/authentication/conflicting_email" }.should route_to(controller: "authentication", action: "update_conflicting_email")
    end

    it "recognizes and generates GET #conflicting_email" do
      { get: '/authentication/fb_linking_success' }.should route_to(controller: "authentication", action: "fb_linking_success")
    end

  end

end
