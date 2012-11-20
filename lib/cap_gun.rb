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

# Tell everyone about your releases!  Send email notification after Capistrano deployments!  Rule the world!
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
  # This mailer is configured with a capistrano variable called "cap_gun_email_envelope"
  class Mailer < ActionMailer::Base

      def self.load_mailer_config(cap)
       raise ArgumentError, "Need at least one recipient." if !cap.exists?(:cap_gun_email_envelope) || cap[:cap_gun_email_envelope][:recipients].blank?
      end

      # Grab the options for emailing from capistrano[:cap_gun_email_envelope] (should be set in your deploy file)
      #
      # Valid options:
      #     :recipients     (required) an array or string of email address(es) that should get notifications
      #     :from           the sender of the notification, defaults to cap_gun@example.com
      #     :email_prefix   subject prefix, defaults to [DEPLOY]
      def deployment_notification(capistrano)
        presenter = Presenter.new(capistrano)
        mail(
          :from     => presenter.from,
          :to       => presenter.recipients,
          :subject  => presenter.subject
        ) do |format|
          format.text { render :text => presenter.body }
        end
      end
    end

end

if Object.const_defined?("Capistrano")

  Capistrano::Configuration.instance(:must_exist).load do

    namespace :cap_gun do
      desc "Send notification of the current release and the previous release via email."
      task :email, :roles => :app do
        CapGun::Mailer.load_mailer_config(self)
        CapGun::Mailer.deployment_notification(self).deliver
      end
    end

  end
end
