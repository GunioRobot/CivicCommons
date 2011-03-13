class Registrations::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    if signed_in? && !current_person.facebook_authenticated?
      authentication = Authentication.new_from_auth_hash(env['omniauth.auth'])
      if current_person.link_with_facebook(authentication)
        successfully_linked_to_facebook
      else
        failed_linked_to_facebook
      end
    elsif authentication = Authentication.find_from_auth_hash(env['omniauth.auth'])
      successful_authentication(authentication)
    else
      render_js_redirect_to(root_path)
    end
  end

private
  def auth_popup?
    params[:auth_popup] && params[:auth_popup] == true
  end
  
  def failed_linked_to_facebook
    flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_failure", :kind => "Facebook"
    # redirect_to root_path
    render_js_redirect_to(root_path)
  end
  
  def successfully_linked_to_facebook
    flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_success", :kind => "Facebook"
    # sign_in_and_redirect current_person, :event => :authentication, :bypass => true
    sign_in current_person, :event => :authentication, :bypass => true
    render_js_redirect_to redirect_location(:person, current_person)
  end
  
  def successful_authentication(authentication)
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"      
    # sign_in_and_redirect authentication.person, :event => :authentication
    sign_in authentication.person, :event => :authentication
    render_js_redirect_to redirect_location(:person, authentication.person)
  end
  
  def render_js_redirect_to(path = '', options={})
    text = options.delete(:text) || 'Redirecting back to CivicCommons....'
    
    # we can also use this: window.opener.location.reload(true);
    render :text => "#{text}<script type='text/javascript'>
      if(window.opener) {
        window.opener.onunload = function(){
            window.close();
        };
        window.opener.location = '#{path}';
        }
      </script>"
    # render :text => 'redirecting'
  end  
  
end