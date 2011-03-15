class AuthenticationController < ApplicationController
  before_filter :require_user
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