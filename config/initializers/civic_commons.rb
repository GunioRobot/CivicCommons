if !defined?(Civiccommons::Config)

  module Civiccommons
    class ConfigNotFoundError < ArgumentError; end

    class Config
      CC_CONFIG = YAML.load_file(File.join(Rails.root, "config", "civic_commons.yml"))

      CC_CONFIG[Rails.env].each do |key|
        (class << self; self; end).class_eval do
          define_method key[0] do |*args|
            if key[1].is_a?(Hash)
              key[1].default_proc = Proc.new do |value, key_called|
                raise Civiccommons::ConfigNotFoundError, "Configuration not found. Make sure config/civic_commons.yml has settings for #{Rails.env} => #{key[0]} => #{key_called}."
              end
              key[1]
            else
              key[1]
            end
          end
        end
      end

      def self.setup_default_email
        raise Civiccommons::ConfigNotFoundError, "Please set up the default email address. See the civic_commons.yml.sample for an example." unless self.email.key?('default_email')
      end

      def self.validate_intercept_config
        raise Civiccommons::ConfigNotFoundError, "Please set up the mailer intercept config. See the civic_commons.yml.sample for an example." unless self.mailer.key?('intercept')
      end

      def self.setup_intercept_email
        self.mailer['intercept_email'] = self.email["default_email"] unless self.mailer.key?('intercept_email')
      end

      def self.setup_mailchimp
        unless self.mailer.key?('mailchimp')
          self.mailer['mailchimp'] = false
          Rails.logger.info "Mailchimp default has been set to false"
        end
      end

      setup_default_email
      validate_intercept_config
      setup_intercept_email
      setup_mailchimp
    end
  end

end

