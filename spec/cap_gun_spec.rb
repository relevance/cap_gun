ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'test/unit'
require 'test/spec'
require 'mocha'
require 'net/smtp'
require File.join(File.dirname(__FILE__), *%w[.. lib cap_bot])

describe "CapGun" do
  it "uses action mailer hack" do
    Net::SMTP.new('').respond_to?(:starttls, true).should == true
  end
end

describe "CapGun" do
  include CapGun::Helper
  
  it "parses datetime from release path" do
    time_from_release("/data/foo/releases/20080402152141", "PDT").should == "April 2nd, 2008 3:21 PM PDT"
  end
end