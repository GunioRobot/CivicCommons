class FacebookAuthPage
  
  FACEBOOK_AUTH_HASH = { 
    'credentials' => {'token'=>"1234567890"}, 
    'provider' => "facebook", 
    'uid' => "12345", 
    'user_info' => { 'first_name' => 'John', 'last_name' => 'doe', 'name' => 'John Doe'},
    'extra' => { 'user_hash' => { 'email' => "johnd@test.com" } } 
  } 
  
  def initialize(page)
    @page = page 
  end

  def sign_in
    stub_omniauth
    @page.click_link_or_button 'Sign in with Facebook'
  end
  
  def link_account
    stub_omniauth 
    @page.click_link_or_button "Link my account with Facebook"
  end
  
  def click_connect_with_facebook
    stub_omniauth
    @page.click_link_or_button "Connect with Facebook"
  end

  def stub_omniauth
    OmniAuth.config.add_mock(:facebook, FACEBOOK_AUTH_HASH)
  end

  def visit_callback
    @page.visit '/people/auth/facebook/callback'
  end

end