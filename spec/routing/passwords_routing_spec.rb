require "spec_helper"

describe PasswordsController do
  describe "routing" do

    it "recognizes and generates #fb_auth_change_password" do
      { get: '/people/secret/fb_auth_forgot_password' }.should route_to(controller: "passwords", action: "fb_auth_forgot_password")
    end
    
    it "does not recognize Post to fb_auth_forgot_password" do
      { post: '/people/secret/fb_auth_forgot_password' }.should_not be_routable
    end

  end
end
