ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'net/smtp'
require File.join(File.dirname(__FILE__), *%w[.. lib cap_gun])

describe "CapGun" do
  it "uses action mailer hack" do
    Net::SMTP.new('').respond_to?(:starttls, true).should == true
  end
end

describe "CapGun" do
  include CapGun::Helper
  
  it "raises if we dont have settings" do
    capistrano = stub_everything
    lambda { CapGun::Helper.load_mailer_config(capistrano) }.should.raise(ArgumentError).message.should == "You must define ActionMailer settings in 'cap_gun_action_mailer_config'"
  end
  
  it "gets action mailer config from capistrano" do
    capistrano = stub(:cap_gun_action_mailer_config => {:account => "foo@gmail.com", :password => "password"})
    CapGun::Helper.load_mailer_config(capistrano)
    ActionMailer::Base.smtp_settings.should == {:account => "foo@gmail.com", :password => "password"}
  end
  
  it "parses datetime from release path" do
    time_from_release("/data/foo/releases/20080402152141", "PDT").should == "April 2nd, 2008 3:21 PM PDT"
  end
end


# deploy.rb
# set "cap_gun_action_mailer_config", { hash of action mailer settings }
# set "cap_gun_options", {:recipients => "foo"}
