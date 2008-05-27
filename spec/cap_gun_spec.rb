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
    
    it "raises if we don't have settings" do
      capistrano = stub_everything
      lambda { CapGun::Helper.load_mailer_config(capistrano) }.should.raise(ArgumentError).message.should == "You must define ActionMailer settings in 'cap_gun_action_mailer_config'"
    end
  
    it "gets action mailer config from capistrano" do
      capistrano = stub(:cap_gun_action_mailer_config => {:account => "foo@gmail.com", :password => "password"}, :exists? => true)
      capistrano.stubs(:[]).returns({:recipients => 'foo'})
      CapGun::Helper.load_mailer_config(capistrano)
      ActionMailer::Base.smtp_settings.should == {:account => "foo@gmail.com", :password => "password"}
    end
    
    it "raises if we have no cap gun email envelope" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :exists? => false)
      lambda { CapGun::Helper.load_mailer_config capistrano }.should.raise(ArgumentError)
    end
    
    it "raises if we don't have at least one recipient" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {})
      lambda { CapGun::Helper.load_mailer_config capistrano }.should.raise(ArgumentError)
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {:recipients => []})
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
    
  end
  
  describe "handling release time" do
      include CapGun::Helper
    
    before do # make DateTime act as if local timezone is EDT
      stubs(:local_timezone).returns("EDT")
      stubs(:local_datetime_zone_offset).returns(Rational(-1,6))
    end
    
    it "returns nil for weird release path" do
      humanize_release_time("/data/foo/my_release").should == nil
    end
    
    it "parse datetime from release path" do
      humanize_release_time("/data/foo/releases/20080227120000").should == "February 27th, 2008 8:00 AM EDT"
    end
    
    it "converts time from release into localtime" do
      humanize_release_time("/data/foo/releases/20080410040000").should == "April 10th, 2008 12:00 AM EDT"
    end
    
  end
  
  describe "Mailer" do
    
    it "passes capistrano into create body" do
      capistrano = { :current_release => "/data/foo", :previous_release => "/data/foo", :cap_gun_email_envelope => {:recipients => ["joe@example.com"]} }
      CapGun::Mailer.any_instance.expects(:create_body).with(capistrano).returns("foo")
      CapGun::Mailer.create_deployment_notification capistrano
      
    end
  end
  
  describe "Mail envelope" do
    before { CapGun::Mailer.any_instance.stubs(:create_body).returns("email body!") }
    
    it "gets recipients from email envelope" do
      capistrano = { :cap_gun_email_envelope => { :recipients => ["foo@here.com", "bar@here.com"] } }
      mail = CapGun::Mailer.create_deployment_notification capistrano
      mail.to.should == ["foo@here.com", "bar@here.com"]
    end

    it "should have a default sender" do
      capistrano = { :cap_gun_email_envelope => { :recipients => "foo@here.com" } }
      mail = CapGun::Mailer.create_deployment_notification capistrano
      mail.from.should == ["cap_gun@example.com"]
    end
    
    it "should override sender from email envelope" do
      capistrano = { :cap_gun_email_envelope => { :from => "booyakka!@example.com", :recipients => ["foo@here.com", "bar@here.com"] } }
      mail = CapGun::Mailer.create_deployment_notification capistrano
      mail.from.should == ["booyakka!@example.com"]
    end
  end
  
  describe "creating body" do
    it "has a friendly summary line" do
      capistrano = { :application => "my app", :rails_env => "staging", :current_release => "/data/foo/releases/20080227120000", :cap_gun_email_envelope => { :from => "booyakka!@example.com", :recipients => ["foo@here.com", "bar@here.com"] } }
      mail = CapGun::Mailer.create_deployment_notification capistrano
      mail.body.split("\n").first.should == "my app was deployed to staging by rsanheim at February 27th, 2008 8:00 AM EDT."
    end

    it "does not include rails env in summary if not defined" do
      capistrano = { :application => "my app", :current_release => "/data/foo/releases/20080227120000", :cap_gun_email_envelope => { :from => "booyakka!@example.com", :recipients => ["foo@here.com", "bar@here.com"] } }
      mail = CapGun::Mailer.create_deployment_notification capistrano
      mail.body.split("\n").first.should == "my app was deployed by rsanheim at February 27th, 2008 8:00 AM EDT."
    end
    
  end
  
end