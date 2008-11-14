require 'action_mailer'
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
  VERSION = '0.0.9'

  module Helper
    
    # Loads ActionMailer settings from a Capistrano variable called "cap_gun_action_mailer_config"
    def load_mailer_config(cap) 
      raise ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'" unless cap.cap_gun_action_mailer_config 
      raise ArgumentError, "Need at least one recipient." if !cap.exists?(:cap_gun_email_envelope) || cap[:cap_gun_email_envelope][:recipients].blank?
      
      ActionMailer::Base.smtp_settings = cap.cap_gun_action_mailer_config
    end
  
    # Current user - unsupported on Windows, patches welcome
    def current_user
      platform.include?('mswin') ? nil : `id -un`.strip
    end
    
    # stub hook purposes only
    def platform
      RUBY_PLATFORM
    end
  
    # Gives you a prettier date/time for output from the standard Capistrano timestamped release directory.
    # This assumes Capistrano uses UTC for its date/timestamped directories, and converts to the local
    # machine timezone.
    def humanize_release_time(path)
      return unless path
      match = path.match(/(\d+)$/)
      return unless match
      local = convert_from_utc(match[1])
      local.strftime("%B #{local.day.ordinalize}, %Y %l:%M %p #{local_timezone}").gsub(/\s+/, ' ').strip
    end
    
    # Use some DateTime magicrey to convert UTC to the current time zone
    # When the whole world is on Rails 2.1 (and therefore new ActiveSupport) we can use the magic timezone support there.
    def convert_from_utc(timestamp)
      # we know Capistrano release timestamps are UTC, but Ruby doesn't, so make it explicit
      utc_time = timestamp << "UTC" 
      datetime = DateTime.parse(utc_time)
      datetime.new_offset(local_datetime_zone_offset)
    end
    
    def local_datetime_zone_offset
      @local_datetime_zone_offset ||= DateTime.now.offset
    end
    
    def local_timezone
      @current_timezone ||= Time.now.zone
    end
    
    extend self
  end
  
  # This mailer is configured with a capistrano variable called "cap_gun_email_envelope"
  class Mailer < ActionMailer::Base
      include CapGun::Helper
      DEFAULT_SENDER = %("CapGun" <cap_gun@example.com>)
      DEFAULT_EMAIL_PREFIX = "[DEPLOY]"
      
      adv_attr_accessor :email_prefix
      attr_accessor :summary
      
      # Grab the options for emailing from cap_gun_email_envelope (should be set in your deploy file)
      #
      # Valid options:
      #     :recipients     (required) an array or string of email address(es) that should get notifications
      #     :from           the sender of the notification, defaults to cap_gun@example.com
      #     :email_prefix   subject prefix, defaults to [DEPLOY]
      def init(envelope = {})
        recipients envelope[:recipients]
        from (envelope[:from] || DEFAULT_SENDER)
        email_prefix (envelope[:email_prefix] || DEFAULT_EMAIL_PREFIX)
      end
      
      # Do the actual email
      def deployment_notification(capistrano)
        init(capistrano[:cap_gun_email_envelope])
        self.summary = create_summary(capistrano)
        
        content_type "text/plain"
        subject "#{email_prefix} #{capistrano[:application]} #{deployed_to(capistrano)}"
        body    create_body(capistrano)
      end
      
      def create_summary(capistrano)
        %[#{capistrano[:application]} was deployed#{" to " << capistrano[:rails_env] if capistrano[:rails_env]} by #{current_user} at #{humanize_release_time(capistrano[:current_release])}.]
      end
      
      def deployed_to(capistrano)
        returning(deploy_msg = "deployed") { |msg| msg << " to #{capistrano[:rails_env]}" if capistrano[:rails_env] }
      end
      
      # Create the body of the message using a bunch of values from Capistrano
      def create_body(capistrano)
<<-EOL
#{summary}

Comment: #{capistrano[:comment] || "[none given]"}

Nerd details
============
Release: #{capistrano[:current_release]}
Release Time: #{humanize_release_time(capistrano[:current_release])}
Release Revision: #{capistrano[:current_revision]}

Previous Release: #{capistrano[:previous_release]}
Previous Release Time: #{humanize_release_time(capistrano[:previous_release])}
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
      desc "Send notification of the current release and the previous release via email."
      task :email do
        CapGun::Helper.load_mailer_config(self)
        CapGun::Mailer.deliver_deployment_notification(self)
      end
    end
    
  end
end