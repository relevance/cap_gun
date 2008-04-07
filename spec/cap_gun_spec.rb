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

  describe "mail settings" do
    include CapGun::Helper
    
    it "raises if we dont have settings" do
      capistrano = stub_everything
      lambda { CapGun::Helper.load_mailer_config(capistrano) }.should.raise(ArgumentError).message.should == "You must define ActionMailer settings in 'cap_gun_action_mailer_config'"
    end
  
    it "gets action mailer config from capistrano" do
      capistrano = stub(:cap_gun_action_mailer_config => {:account => "foo@gmail.com", :password => "password"}, :exists? => true, :cap_gun_options => {:recipients => "foo"})
      CapGun::Helper.load_mailer_config(capistrano)
      ActionMailer::Base.smtp_settings.should == {:account => "foo@gmail.com", :password => "password"}
    end
    
    it "raises if we have no cap gun options" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :exists? => false)
      lambda { CapGun::Helper.load_mailer_config capistrano }.should.raise(ArgumentError)
    end
    
    it "raises if we dont have at least one recipient" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_options => {})
      lambda { CapGun::Helper.load_mailer_config capistrano }.should.raise(ArgumentError)
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_options => {:recipients => []})
      lambda { CapGun::Helper.load_mailer_config capistrano }.should.raise(ArgumentError)
    end
    
  end
  
  describe "misc helpers" do
    include CapGun::Helper
    
    it "returns nil for current user if platform is win32" do
      expects(:platform).returns("mswin")
      current_user.should.be nil
    end
    
    it "should get current user from *nix id command" do
      expects(:"`").with('id -un').returns("joe")
      current_user
    end
    
    it "returns nil for weird release path" do
      time_from_release("/data/foo/my_release", "PDT").should == nil
    end
    
    it "parse datetime from release path" do
      time_from_release("/data/foo/releases/20080402152141", "PDT").should == "April 2nd, 2008 3:21 PM PDT"
    end
    
  end
  
  describe "Mailer" do
    it "passes capistrano into create body" do
      capistrano = { :current_release => "/data/foo", :previous_release => "/data/foo", :cap_gun_options => {:recipients => ["joe@example.com"]} }
      CapGun::Mailer.any_instance.expects(:create_body).with(capistrano).returns("foo")
      CapGun::Mailer.create_deployment_notification capistrano
      
    end
    
  end
  
end


# deploy.rb
# set "cap_gun_action_mailer_config", { hash of action mailer settings }
# set "cap_gun_options", {:recipients => "foo"}
