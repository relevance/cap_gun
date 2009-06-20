ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'net/smtp'
require 'redgreen' unless Object.const_defined?("TextMate")

require File.join(File.dirname(__FILE__), *%w[.. lib cap_gun presenter])

describe "handling release time" do
  
  before do # make DateTime act as if local timezone is CDT
    @presenter = CapGun::Presenter.new(nil)
    @presenter.stubs(:local_timezone).returns("CDT")
    @presenter.stubs(:local_datetime_zone_offset).returns(Rational(-1,6))
  end
  
  it "returns nil for weird release path" do
    @presenter.humanize_release_time("/data/foo/my_release").should == nil
  end
  
  it "parse datetime from release path" do
    @presenter.humanize_release_time("/data/foo/releases/20080227120000").should == "February 27th, 2008 8:00 AM CDT"
  end
  
  it "converts time from release into localtime" do
    @presenter.humanize_release_time("/data/foo/releases/20080410040000").should == "April 10th, 2008 12:00 AM CDT"
  end
  
end

describe "from and to emails" do
  it "gets recipients from email envelope" do
    capistrano = { :cap_gun_email_envelope => { :recipients => ["foo@here.com", "bar@here.com"] } }
    presenter = CapGun::Presenter.new(capistrano)
    presenter.recipients.should == ["foo@here.com", "bar@here.com"]
  end

  it "should have a default sender" do
    capistrano = { :cap_gun_email_envelope => { } }
    presenter = CapGun::Presenter.new(capistrano)
    presenter.from.should == "\"CapGun\" <cap_gun@example.com>"
  end
  
  it "should override sender from email envelope" do
    capistrano = { :cap_gun_email_envelope => { :from => "booyakka!@example.com" } }
    presenter = CapGun::Presenter.new(capistrano)
    presenter.from.should == "booyakka!@example.com"
  end
end

