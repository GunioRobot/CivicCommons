require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "8457517 link local account with facebook", %q{
  In order use CivicCommons
  As an existing user with a local account
  I want to authenticate through Facebook
  So that I only have to remember one login and password
} do
  
  before do
    login_page.sign_out
  end

  let (:facebook_auth_page)         { FacebookAuthPage.new(page) }
  let (:login_page)                 { LoginPage.new(page) }
  let (:settings_page)              { SettingsPage.new(page) }
  let (:conflicting_email_page)     { ConflictingEmailPage.new(page) }
  let (:fb_linking_success_page)    { FbLinkingSuccessPage.new(page) }
  let (:suggest_facebook_auth_page) { SuggestFacebookAuthPage.new(page) }
  
  def response_should_js_redirect_to(path)
    page.should contain "window.opener.location = '#{path}'"
  end

  def response_should_js_open_colorbox(path)
    page.should contain "window.opener.$.colorbox({href:'#{path}'" 
  end

  context "When I have not linked my account to Facebook" do
    
    def given_a_registered_user
      @person = Factory.create(:registered_user,:email => 'johnd@test.com')
    end
    
    def given_a_registered_user_for_conflicting_fb_email
      @person = Factory.create(:registered_user, :email => "johnd-conflicting-email@test.com") 
    end
    
    scenario "I should be allowed to resolve my conflicting email when I'm linking with Facebook" do
      # Given I am a registered user that also has an unlinked Facebook account with a different email address
      given_a_registered_user_for_conflicting_fb_email
      
      # And I login
      login_page.sign_in(@person)
      
      # And I go to the settings page
      settings_page.visit(@person)
      
      # When I click on 'Connect with Facebook'
      facebook_auth_page.click_connect_with_facebook
      
      # Then it should  open a modal dialog of Facebook linking success 
      response_should_js_open_colorbox(conflicting_email_path)
      conflicting_email_page.visit
      
      # When I click yes
      conflicting_email_page.click_yes
      
      # Then it should show me the successful confirmation dialog box
      # (this is a cheat, because the js is supposed to post and then redirect to fb_linking_success page on success)
      page.driver.response.status.should == 200
      fb_linking_success_page.visit
      page.should contain 'Successfully linked your account to Facebook'
      
    end
    
    context "Facebook suggest modal dialogue" do
      scenario "should be displayed if I have not linked my account to facebook" do
        # Given I am a newly registered user
        given_a_registered_user
        
        # And I logged in
        login_page.sign_in(@person)
        
        # Then I should see a suggestion for Facebook link modal
        page.should contain suggest_facebook_auth_page.modal
      end
      scenario "should be not be displayed when I have declined the suggestion to link to Facebook" do
        # Given I am a registered user
        given_a_registered_user
        
        # And I logged in
        login_page.sign_in(@person)
        
        # Then I should see a suggestion for Facebook link modal
        page.should contain suggest_facebook_auth_page.modal
        
        # And I declined the Suggest Facebook auth page
        suggest_facebook_auth_page.click_decline
        
        # And I logged out
        login_page.sign_out
        
        # When I logged in again
        login_page.sign_in(@person)
        
        # Then I should not see the suggest modal
        page.should_not contain suggest_facebook_auth_page.modal
      end
    end

    scenario "I should be able to link my account to facebook from the 'accounts' page" do
      # Given I am a registered user
      given_a_registered_user
      
      # When I visit the hompage
      visit homepage
      
      # And I logged in
      login_page.sign_in(@person)
      
      # And I go to the settings page
      settings_page.visit(@person)
      
      # Then I should be on the settings page
      should_be_on edit_user_path(@person)
      
      # And it should have the link 'Connect with Facebook'
      page.should have_link 'Connect with Facebook'
      
      # When I click on 'Connect with Facebook'
      facebook_auth_page.click_connect_with_facebook
      
      # Then it should  open a modal dialog of Facebook linking success 
      response_should_js_open_colorbox(fb_linking_success_path)
      
      # When I go to settings page 
      settings_page.visit(@person)
      
      # Then it should not have 'Connect with Facebook' link
      page.should_not have_link 'Connect with Facebook'
      
      # And it should have 'Unlink Account' link
      page.should have_link "Unlink Account"
    end
    
  end
  
  context "When I already have linked my account to facebook previously" do
    
    def given_a_registered_user_w_facebook_auth
      @person = Factory.create(:registered_user)
      @facebook_auth = Factory.build(:facebook_authentication)
      @person.link_with_facebook(@facebook_auth)
    end

    scenario "I should be able to login using facebook and to existing account" do
      # Given I am a registered user with Facebook Auth
      given_a_registered_user_w_facebook_auth
      
      # When I visit the homepage
      visit homepage
      
      # Then I should have the link 'Sign in with Facebook'
      page.should have_link 'Sign in with Facebook'
      
      # And I should not have my name on the site(because I haven't logged in yet)
      page.should_not have_content "John Doe"
      
      # When I sign in using Facebook
      facebook_auth_page.sign_in
      
      # Then it should give me a javascript to redirect me to the homepage
      response_should_js_redirect_to(homepage)
      visit homepage
      
      # And I should not see the link 'Sign in with Facebook' anymore
      page.should_not have_link 'Sign in with Facebook'
      
      # And I should see my name there
      page.should have_content "John Doe"      
    end
    
    scenario "I should not be able to login using my existing account anymore" do
      # Given I am a registered user that have connected my account with facebook
      given_a_registered_user_w_facebook_auth
      
      # When I am on the homepage
      visit homepage
      
      # And I try to sign in
      login_page.sign_in(@person)
      
      # Then I should not be able to login
      page.should have_content "Invalid email or password."
    end
    
  end

  context "Facebook profile picture" do
    
    def given_a_registered_user_without_avatar
      @person = Factory.create(:registered_user,:email => 'johnd@test.com', :avatar => nil)
    end
    
    def user_profile_picture
      page.find('#login-status a img.callout')['src']
    end
    
    scenario "I should my facebook profile picture if I've connected to Facebook" do
      # Given I am a registered user
      given_a_registered_user_without_avatar
      
      # And I logged in
      login_page.sign_in(@person)
      
      # When I'm on the homepage
      visit homepage
      
      # Then I should see my avatar(Non Facebook)
      user_profile_picture.should contain "/images/avatar_70.gif"
      
      # When I go to the settings page
      settings_page.visit(@person)
      
      # And I click on 'Connect with Facebook'
      facebook_auth_page.click_connect_with_facebook
      
      # And I go to the homepage again
      visit homepage
      
      # Then I should see my Facebook profile picture
      user_profile_picture.should contain "https://graph.facebook.com/12345/picture"
    end
  end
  
end