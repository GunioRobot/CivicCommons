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
    redirect_to :back
  end
end