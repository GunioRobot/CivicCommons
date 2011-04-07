class FbAuthForgotPasswordModalPage
  attr_accessor :page
  PAGE_PATH = '/people/secret/fb_auth_forgot_password'
  
  def initialize(page)
    @page = page 
  end
  
  def visit
    page.visit PAGE_PATH
  end    
  
end