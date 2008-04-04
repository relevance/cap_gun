require 'active_support'
require 'action_mailer'
require File.join(File.dirname(__FILE__), *%w[.. vendor action_mailer_tls lib smtp_tls])

# Tell everyone about your releases!
# 
# You must set up your mail settings in config/cap_gun_config.yml.  We include
# the ActionMailer hack to play nice with gmail, so thats a super easy way 
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
# Then when you deploy, you can optionally include comments:
#   cap -s comment="fix for bug #303" deploy
#
module CapGun

  module Helper
    
    # Loads ActionMailer settings from a Capistrano variable called "cap_gun_action_mailer_config"
    def load_mailer_config(cap) 
      raise ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'" unless cap.cap_gun_action_mailer_config 
      ActionMailer::Base.smtp_settings = cap.cap_gun_action_mailer_config
    end
  
    # Current user - unsupported on Windows 
    def current_user
      platform.include?('mswin') ? nil : `id -un`.strip
    end
    
    def platform
      RUBY_PLATFORM
    end
  
    def time_from_release(path, timezone)
      match = path.match(/(\d+)$/)
      return unless match
      datetime = DateTime.parse(match[1])
      datetime.strftime("%B #{datetime.day.ordinalize}, %Y %l:%M %p #{timezone}").gsub(/\s+/, ' ').strip
    end
    
    extend self
  end
  
  class Mailer < ActionMailer::Base
      include CapGun::Helper
      DEFAULT_SENDER = %("CapGun" <cap_gun@example.com>)

      @@email_prefix = "[DEPLOY] "
      cattr_accessor :email_prefix
      
      def deployment_notification(capistrano)
        options = capistrano[:cap_gun_options]
        
        content_type "text/plain"
        subject "#{email_prefix} #{capistrano[:application]} deployed to #{capistrano[:rails_env]}"

        recipients options[:recipients]
        from       options[:sender_address] || DEFAULT_SENDER

        body       create_body(capistrano)
      end
      
      def create_body(capistrano)
<<-EOL
#{capistrano[:application]} was deployed to #{capistrano[:rails_env]} by #{current_user} at #{time_from_release(capistrano[:current_release], capistrano[:timezone])}.

Comment: #{capistrano[:comment] || "[none given]"}

Nerd details
============
Release: #{capistrano[:current_release]}
Release Time: #{time_from_release(capistrano[:current_release], capistrano[:timezone])}
Release Revision: #{capistrano[:current_revision]}

Previous Release: #{capistrano[:previous_release]}
Previous Release Time: #{time_from_release(capistrano[:previous_release], capistrano[:timezone])}
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
      desc "Get the time zone from the server"
      task :get_timezone, :roles => :app do
        set "timezone", capture('date "+%Z"').strip
      end
      
      desc "Send notification via email"
      task :email do
        CapGun::Helper.load_mailer_config
        CapGun::Mailer.deliver_deployment_notification(self)
      end

    end
    
    before "cap_gun:email", "cap_gun:get_timezone"
    
  end
end