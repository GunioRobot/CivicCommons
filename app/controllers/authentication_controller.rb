class AuthenticationController < ApplicationController
  before_filter :require_user, :except => [:registering_email_taken]
  def decline_fb_auth
    if current_person.update_attribute(:declined_fb_auth, true)
      render :nothing => true, :status => :ok
    else
      render :text => current_person.errors.full_messages, :status => :unprocessable_entity 
    end
  end
  
  def conflicting_email
    render :layout => false
  end
  
  def registering_email_taken
    render :layout => false
  end
  
  def successful_registration
    render :layout => false
  end

  def successful_fb_registration
    @person = current_person
    render :layout => false
  end
  
  def update_account
    @person = current_person
    if params['person'] && @person.update_attributes({:zip_code => params['person']['zip_code']})
      render :js => "<script type='text/javascript'>$.colorbox({href:'#{successful_registration_path}'})</script>"
    else
      render :template => '/authentication/_update_account_form.html', :layout => false
    end  
  end
  
  def update_conflicting_email
    if !session[:other_email].blank? && current_person.update_attribute(:email, session[:other_email]) 
      session[:other_email] = nil
      render :nothing => true, :status => :ok
    else
      render :text => current_person.errors.full_messages, :status => :unprocessable_entity
    end
  end
  
  def fb_linking_success
    render :layout => false
  end
end