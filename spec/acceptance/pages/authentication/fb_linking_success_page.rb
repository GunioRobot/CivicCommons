class FbLinkingSuccessPage
  
  FB_LINKING_SUCCESS_PATH = '/authentication/fb_linking_success'
  
  attr_accessor :page
    
  def initialize(page)
    @page = page 
  end
  
  def visit
    page.visit FB_LINKING_SUCCESS_PATH
  end
  
end