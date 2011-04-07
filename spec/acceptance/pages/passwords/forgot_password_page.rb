class ForgotPasswordPage
  attr_accessor :page
  PAGE_PATH = '/people/secret/new'
    
  def initialize(page)
    @page = page 
  end
  
  def visit
    page.visit PAGE_PATH
  end
  
  def enter_email(email)
    page.fill_in 'person_email', :with => email
  end
  
  def click_submit
    page.click_button 'person_submit'
  end
  
end