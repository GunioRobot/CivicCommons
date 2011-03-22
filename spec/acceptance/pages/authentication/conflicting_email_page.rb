class ConflictingEmailPage
  
  CONFLICTING_EMAIL_PATH = '/authentication/conflicting_email'
  
  attr_accessor :page
    
  def initialize(page)
    @page = page 
  end
  
  def visit
    page.visit CONFLICTING_EMAIL_PATH
  end
  
  def click_yes
    yes_link = page.find('a.overwrite-email')['href']
    # this is because, we use javascript to do a POST to this url
    Capybara.current_session.driver.process :post, yes_link
  end
  
end