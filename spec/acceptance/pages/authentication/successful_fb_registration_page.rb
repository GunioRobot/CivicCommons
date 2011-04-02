class SuccessfulFbRegistrationPage
  
  SUCCESSFUL_FB_REGISTRATION_PATH = '/authentication/successful_fb_registration'
  
  attr_accessor :page
    
  def initialize(page)
    @page = page 
  end
  
  def click_submit
    page.click_button 'person_submit'
  end
  
  def visit
    page.visit SUCCESSFUL_FB_REGISTRATION_PATH
  end
  
  def fill_in_zip_code_with(zip)
    page.fill_in 'person_zip_code', :with => zip
  end
  
end