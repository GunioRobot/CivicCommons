class Registrations::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    if signed_in? && !current_person.facebook_authenticated?
      link_with_facebook      
    elsif authentication = Authentication.find_from_auth_hash(env['omniauth.auth'])
      successful_authentication(authentication)
    else
      render_js_redirect_to(env['omniauth.origin'] || root_path)
    end
  end

private
  def auth_popup?
    params[:auth_popup] && params[:auth_popup] == true
  end
  
  def failed_linked_to_facebook
    flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_failure", :kind => "Facebook"
    render_js_redirect_to(env['omniauth.origin'] || root_path)
  end
  
  def link_with_facebook
    authentication = Authentication.new_from_auth_hash(env['omniauth.auth'])
    
    if current_person.link_with_facebook(authentication)
      @other_email = Authentication.email_from_auth_hash(env['omniauth.auth'])
      
      sign_in current_person, :event => :authentication, :bypass => true
      if current_person.conflicting_email?(@other_email)
        successfully_linked_but_conflicting_email
      else
        successfully_linked_to_facebook
      end
    else
      failed_linked_to_facebook
    end
  end
  
  def successfully_linked_to_facebook
    flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_success", :kind => "Facebook"
    render_js_fb_linking_success
  end
  
  def successfully_linked_but_conflicting_email
    session[:other_email] = @other_email
    render_js_conflicting_email    
  end
  
  def successful_authentication(authentication)
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
    sign_in authentication.person, :event => :authentication
    render_js_redirect_to (env['omniauth.origin'] || root_path), :text => 'Logging in to CivicCommons with Facebook...'
  end
  
  def render_js_conflicting_email(options={})
    text = options.delete(:text) || 'Redirecting back to CivicCommons....'
    render :text => "#{text}<script type='text/javascript'>
      if(window.opener) {
        window.opener.$.colorbox({href:'#{conflicting_email_path}',opacity:0.5, onComplete: function(){
          window.close();
        }});
        }
      </script>"
  end
  
  def render_js_fb_linking_success(options={})
    text = options.delete(:text) || 'Redirecting back to CivicCommons....'
    render :text => "#{text}<script type='text/javascript'>
      if(window.opener) {
        window.opener.$.colorbox({href:'#{fb_linking_success_path}',opacity:0.5, onComplete: function(){
          window.close();
        }});
        }
      </script>"
  end
  
  def render_js_redirect_to(path = '', options={})
    text = options.delete(:text) || 'Redirecting back to CivicCommons....'
    render :text => "#{text}<script type='text/javascript'>
      if(window.opener) {
        window.opener.onunload = function(){
            window.close();
        };
        window.opener.location = '#{path}';
        }
      </script>"
  end  
  
end