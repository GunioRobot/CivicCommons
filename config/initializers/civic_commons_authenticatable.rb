# A custom Devise strategy for CivicCommons
module Devise
  module Strategies
    class CivicCommonsAuthenticatable < Authenticatable 
      def authenticate!
        resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)

        if validate(resource){ resource.valid_password?(password) }
          resource.after_database_authentication
          success!(resource)
        elsif resource.respond_to?(:facebook_authenticated?) && resource.facebook_authenticated?
          fail!(:facebook_authenticated)
        else
          fail!(:invalid)
        end
        
      end
    end
  end
end

Warden::Strategies.add(:civic_commons_authenticatable, Devise::Strategies::CivicCommonsAuthenticatable)
