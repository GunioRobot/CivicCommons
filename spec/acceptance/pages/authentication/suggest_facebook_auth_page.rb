class SuggestFacebookAuthPage
  
  DECLINE_FACEBOOK_AUTH = '/authentication/decline_fb_auth'
  
  attr_accessor :page
    
  def initialize(page)
    @page = page 
  end
  
  def click_decline
    Capybara.current_session.driver.process :post, DECLINE_FACEBOOK_AUTH
  end
  
  def modal
    %q[$.colorbox({opacity:0.5, html:'<div class=\"suggest-auth facebook-auth\"]
  end
  
  def title
    'Have a Facebook account?'
  end
  
end