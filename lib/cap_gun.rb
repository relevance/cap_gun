require 'active_support'

begin
  # This requires the full active_support.
  # ActiveSupport v3 and up are modular and 
  # need to be explicitly loaded.
  # Rescue in cases of ActiveSupport 2.3.2 and earlier.
  require 'active_support/all'
rescue
  # Do nothing, everything should be included
  # by default in older versions of ActiveSupport.
end

require 'action_mailer'

require File.join(File.dirname(__FILE__), *%w[cap_gun presenter])
require File.join(File.dirname(__FILE__), *%w[.. vendor action_mailer_tls lib smtp_tls])

# Tell everyone about your releases!  Send email notification after Capistrano deployments!  Rule the world!
# 
# We include the ActionMailer hack to play nice with Gmail, so that's a super easy way 
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
# See README for full install/config instructions.
module CapGun
  VERSION = '0.2.4'

  # This mailer is configured with a capistrano variable called "cap_gun_email_envelope"
  class Mailer < ActionMailer::Base

      def self.load_mailer_config(cap)
       raise ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'" unless cap.cap_gun_action_mailer_config
       raise ArgumentError, "Need at least one recipient." if !cap.exists?(:cap_gun_email_envelope) || cap[:cap_gun_email_envelope][:recipients].blank?

       ActionMailer::Base.smtp_settings = cap.cap_gun_action_mailer_config
      end
      
      # Grab the options for emailing from capistrano[:cap_gun_email_envelope] (should be set in your deploy file)
      #
      # Valid options:
      #     :recipients     (required) an array or string of email address(es) that should get notifications
      #     :from           the sender of the notification, defaults to cap_gun@example.com
      #     :email_prefix   subject prefix, defaults to [DEPLOY]
      def deployment_notification(capistrano)
        presenter = Presenter.new(capistrano)
        
        content_type "text/plain"
        from         presenter.from
        recipients   presenter.recipients
        subject      presenter.subject
        body         presenter.body
      end
    end
    
end

if Object.const_defined?("Capistrano")

  Capistrano::Configuration.instance(:must_exist).load do

    namespace :cap_gun do
      desc "Send notification of the current release and the previous release via email."
      task :email, :roles => :app do
        CapGun::Mailer.load_mailer_config(self)
        if CapGun::Mailer.respond_to?(:deliver_deployment_notification)
          CapGun::Mailer.deliver_deployment_notification(self)
        else
          CapGun::Mailer.deployment_notification(self).deliver
        end
      end
    end
    
  end
end
