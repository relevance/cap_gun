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
  VERSION = '0.0.11'

  module Helper
    
    # Loads ActionMailer settings from a Capistrano variable called "cap_gun_action_mailer_config"
    def load_mailer_config(cap) 
      raise ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'" unless cap.cap_gun_action_mailer_config 
      raise ArgumentError, "Need at least one recipient." if !cap.exists?(:cap_gun_email_envelope) || cap[:cap_gun_email_envelope][:recipients].blank?
      
      ActionMailer::Base.smtp_settings = cap.cap_gun_action_mailer_config
    end
  
    extend self
  end
  
  class Presenter
    
    # Gives you a prettier date/time for output from the standard Capistrano timestamped release directory.
    # This assumes Capistrano uses UTC for its date/timestamped directories, and converts to the local
    # machine timezone.
    def humanize_time(path)
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
    
    attr_accessor :capistrano
    
    def initialize(capistrano)
      self.capistrano = capistrano
    end
    
    DEFAULT_SENDER = %("CapGun" <cap_gun@example.com>)
    DEFAULT_EMAIL_PREFIX = "[DEPLOY]"

    # stub hook purposes only
    def platform
      RUBY_PLATFORM
    end

    def rails_env
      capistrano[:rails_env]
    end

    def release_time
      humanize_time(capistrano[:current_release])
    end
    
    # Current user - unsupported on Windows, patches welcome
    def current_user
      platform.include?('mswin') ? nil : `id -un`.strip
    end

    def summary
      %[#{capistrano[:application]} was #{deployed_to} by #{current_user} at #{release_time}.]
    end

    def deployed_to
      return "deployed to #{rails_env}" if rails_env
      "deployed"
    end

    def branch
      "Branch: #{capistrano[:branch]}" unless capistrano[:branch].nil? || capistrano[:branch].empty?
    end

    def git_details
      return unless capistrano[:scm] == :git
      <<-EOL
#{branch}
#{git_log}
      EOL
      rescue
        nil
    end

    def git_log
      "\nCommits since last release\n====================\n#{git_log_messages}"
    end

    def git_log_messages
      `git log #{capistrano[:previous_revision]}..#{capistrano[:current_revision]} --pretty=format:%h:%s`
    end

    def previous_release_time 
      humanize_time(capistrano[:previous_release])
    end

    # Create the body of the message using a bunch of values from Capistrano
    def body
<<-EOL
#{summary}
#{comment}
Nerd details
============
Release: #{capistrano[:current_release]}
Release Time: #{release_time}
Release Revision: #{capistrano[:current_revision]}

Previous Release: #{capistrano[:previous_release]}
Previous Release Time: #{previous_release_time}
Previous Release Revision: #{capistrano[:previous_revision]}

Repository: #{capistrano[:repository]}
Deploy path: #{capistrano[:deploy_to]}
Domain: #{capistrano[:domain]}
#{git_details}
EOL
    end

    def envelope
      capistrano[:cap_gun_email_envelope]
    end

    def recipients
      envelope[:recipients]
    end

    def email_prefix
      envelope[:email_prefix] || DEFAULT_EMAIL_PREFIX
    end

    def from
      envelope[:from] || DEFAULT_SENDER
    end

    def subject
      "#{email_prefix} #{capistrano[:application]} #{deployed_to}"
    end
    
    def comment
      "Comment: #{capistrano[:comment]}.\n" if capistrano[:comment]
    end

  end
  
  # This mailer is configured with a capistrano variable called "cap_gun_email_envelope"
  class Mailer < ActionMailer::Base
      include CapGun::Helper
      
      adv_attr_accessor :email_prefix
      
      # Grab the options for emailing from capistrano[:cap_gun_email_envelope] (should be set in your deploy file)
      #
      # Valid options:
      #     :recipients     (required) an array or string of email address(es) that should get notifications
      #     :from           the sender of the notification, defaults to cap_gun@example.com
      #     :email_prefix   subject prefix, defaults to [DEPLOY]
      #
      #
      def deployment_notification(capistrano)
        presenter = Presenter.new(capistrano)
        
        content_type "text/plain"
        email_prefix presenter.email_prefix
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
      task :email do
        CapGun::Helper.load_mailer_config(self)
        CapGun::Mailer.deliver_deployment_notification(self)
      end
    end
    
  end
end