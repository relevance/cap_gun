require 'active_support'
require 'action_mailer'
require File.join(File.dirname(__FILE__), *%w[.. vendor action_mailer_tls lib smtp_tls])

# Tell everyone about your releases!  Send email notification after Capistrano deployments!  Rule the world!
# 
# We include the ActionMailer hack to play nice with gmail, so thats a super easy way 
# to do this without setting up your own MTA.
#
# Example:
#
# Want to just shoot everyone an email about the latest status?
#
#   cap cap_gun:email
# 
# Include comments?
#
#   cap -s comment="hi mom" cap_gun:email
#
# Enable emails after every deploy by adding this to your deploy.rb:
# 
#   after "deploy", "cap_gun:email"
#
# Now, next time you deploy, you can optionally include comments:
#
#   cap -s comment="fix for bug #303" deploy
#
module CapGun
  VERSION = '0.0.1'

  module Helper
    
    # Loads ActionMailer settings from a Capistrano variable called "cap_gun_action_mailer_config"
    def load_mailer_config(cap) 
      raise ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'" unless cap.cap_gun_action_mailer_config 
      raise ArgumentError, "Need at least one recipient." if !cap.exists?(:cap_gun_email_envelope) || cap[:cap_gun_email_envelope][:recipients].blank?
      
      ActionMailer::Base.smtp_settings = cap.cap_gun_action_mailer_config
    end
  
    # Current user - unsupported on Windows 
    def current_user
      platform.include?('mswin') ? nil : `id -un`.strip
    end
    
    # stub hook purposes only
    def platform
      RUBY_PLATFORM
    end
  
    def humanize_release_time(path, timezone)
      match = path.match(/(\d+)$/)
      return unless match
      datetime = DateTime.parse(match[1])
      datetime.strftime("%B #{datetime.day.ordinalize}, %Y %l:%M %p #{timezone}").gsub(/\s+/, ' ').strip
    end
    
    extend self
  end
  
  # This mailer is configued with a capistrano variable called "cap_gun_email_envelope"
  class Mailer < ActionMailer::Base
      include CapGun::Helper
      DEFAULT_SENDER = %("CapGun" <cap_gun@example.com>)
      DEFAULT_EMAIL_PREFIX = "[DEPLOY] "
      
      attr_accessor :email_prefix
      
      # Grab the options for emaililng from cap_gun_email_envelope
      def init(envelope = {})
        recipients envelope[:recipients]
        from envelope[:from] || DEFAULT_SENDER
        email_prefix = (envelope[:email_prefix] || DEFAULT_EMAIL_PREFIX)
        
      end
      
      def deployment_notification(capistrano)
        content_type "text/plain"
        
        init(capistrano[:cap_gun_email_envelope])
        
        subject "#{email_prefix} #{capistrano[:application]} deployed to #{capistrano[:rails_env]}"

        body       create_body(capistrano)
      end
      
      def create_body(capistrano)
<<-EOL
#{capistrano[:application]} was deployed to #{capistrano[:rails_env]} by #{current_user} at #{humanize_release_time(capistrano[:current_release], capistrano[:timezone])}.

Comment: #{capistrano[:comment] || "[none given]"}

Nerd details
============
Release: #{capistrano[:current_release]}
Release Time: #{humanize_release_time(capistrano[:current_release], capistrano[:timezone])}
Release Revision: #{capistrano[:current_revision]}

Previous Release: #{capistrano[:previous_release]}
Previous Release Time: #{humanize_release_time(capistrano[:previous_release], capistrano[:timezone])}
Previous Release Revision: #{capistrano[:previous_revision]}

Repository: #{capistrano[:repository]}
Deploy path: #{capistrano[:deploy_to]}
EOL
      end
    end

end

if Object.const_defined?("Capistrano")

  Capistrano::Configuration.instance(:must_exist).load do

    namespace :cap_gun do
      desc "Send notification via email"
      task :email do
        CapGun::Helper.load_mailer_config(self)
        CapGun::Mailer.deliver_deployment_notification(self)
      end
    end
    
  end
end