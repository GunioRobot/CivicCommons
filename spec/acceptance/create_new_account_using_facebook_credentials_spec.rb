require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Create New Account Using Facebook Credentials", %q{
  In order to use CivicCommons
  As a visitor of CivicCommons
  I want to create a new account using Facebook Credentials
} do
  
  let (:facebook_auth_page) { FacebookAuthPage.new(page) }
  let (:login_page) { LoginPage.new(page) }
  let (:successful_fb_registration_page) { SuccessfulFbRegistrationPage.new(page) }
  
  def response_should_js_redirect_to(path)
    page.should contain "window.opener.location = '#{path}'"
  end
  
  def response_should_js_open_colorbox(path)
    page.should contain "$.colorbox({href:'#{path}'"
  end
  
  def given_existing_user_with_same_email
    Factory.create(:registered_user, :email => 'johnd@test.com')
  end
  
  before do
    login_page.sign_out
  end
  
  scenario "Creating an account using Facebook credentials" do
    # Given I am on the homepage
    visit homepage
    
    # Then I should have the link 'Sign in with Facebook'
    page.should have_link 'Sign in with Facebook'
    
    # And I should not have my name on the site(because I haven't logged in yet)
    page.should_not have_content "John Doe"
    
    # When I create an account using Facebook
    facebook_auth_page.sign_in
    
    # Then it should give me a javascript to redirect me to the homepage
    response_should_js_redirect_to(homepage)
    visit homepage
    
    #And I should not see the link 'Sign in with Facebook' anymore
    page.should_not have_link 'Sign in with Facebook'
    
    # And I should see my name there
    page.should have_content "John Doe"
    
    # And I should see an successful creation of account using Facebook credesntials, and also with ZipCode prompt
    response_should_js_open_colorbox(successful_fb_registration_path)
    successful_fb_registration_page.visit
    
    # When I enter the zipcode
    successful_fb_registration_page.fill_in_zip_code_with('12345')
    
    # And I click submit
    successful_fb_registration_page.click_submit
    
    # Then I should see a successful confirmation
    response_should_js_open_colorbox(successful_registration_path)
  end
  scenario "email is taken" do
    # Given there is an existing user with the same email in system
    given_existing_user_with_same_email
    
    # Given I am on the homepage
    visit homepage
    
    # Then I should have the link 'Sign in with Facebook'
    page.should have_link 'Sign in with Facebook'
    
    # When I try to register using Facebook
    facebook_auth_page.sign_in
    
    # Then I should see Conflictinng email colorbox
    response_should_js_open_colorbox(registering_email_taken_path)
    visit homepage
    
    #And I should see the link 'Sign in with Facebook'
    page.should have_link 'Sign in with Facebook'
  end
end
