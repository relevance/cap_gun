require File.join(File.dirname(__FILE__), *%w[example_helper])

describe CapGun do

  it "uses action mailer hack" do
    Net::SMTP.new('').respond_to?(:starttls, true).should == true
  end

  describe "mail settings" do
    
    it "raises if we don't have settings" do
      capistrano = stub_everything
      lambda { 
        CapGun::Mailer.load_mailer_config(capistrano) 
      }.should raise_error(ArgumentError, "You must define ActionMailer settings in 'cap_gun_action_mailer_config'")
    end
  
    it "gets action mailer config from capistrano" do
      capistrano = stub(:cap_gun_action_mailer_config => {:account => "foo@gmail.com", :password => "password"}, :exists? => true)
      capistrano.stubs(:[]).returns({:recipients => 'foo'})
      CapGun::Mailer.load_mailer_config(capistrano)
      ActionMailer::Base.smtp_settings.should == {:account => "foo@gmail.com", :password => "password"}
    end
    
    it "raises if don't have a cap gun email envelope" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :exists? => false)
      lambda { 
        CapGun::Mailer.load_mailer_config capistrano 
      }.should raise_error(ArgumentError)
    end
    
    it "raises if we don't have at least one recipient" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {})
      lambda { 
        CapGun::Mailer.load_mailer_config capistrano 
      }.should raise_error(ArgumentError)
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {:recipients => []})
      lambda { 
        CapGun::Mailer.load_mailer_config capistrano 
      }.should raise_error(ArgumentError)
    end
    
  end
  
  describe CapGun::Mailer do
    
    it "calls Net::SMTP to send the mail correctly (we test this because SMTP internals changed between 1.8.6 and newer versions of Ruby)" do
      ActionMailer::Base.smtp_settings = {
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => "foo.com",
        :authentication => :plain,
        :user_name => "username",
        :password => "password"
      }
    
      capistrano = { :current_release => "/data/foo", :previous_release => "/data/foo", :cap_gun_email_envelope => {:recipients => ["joe@example.com"]} }        
      smtp = Net::SMTP.new('gmail.com', 25)
      Net::SMTP.expects(:new).returns(smtp)
      smtp.expects(:start)
      CapGun::Mailer.deliver_deployment_notification capistrano
    end
    
  end
  
end