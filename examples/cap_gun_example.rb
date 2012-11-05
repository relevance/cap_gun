require File.join(File.dirname(__FILE__), *%w[example_helper])

describe CapGun do
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
        CapGun::Mailer.load_mailer_config(capistrano)
      }.should raise_error(ArgumentError)
    end

    it "raises if we don't have at least one recipient" do
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {})
      lambda {
        CapGun::Mailer.load_mailer_config(capistrano)
      }.should raise_error(ArgumentError)
      capistrano = stub_everything(:cap_gun_action_mailer_config => {}, :cap_gun_email_envelope => {:recipients => []})
      lambda {
        CapGun::Mailer.load_mailer_config(capistrano)
      }.should raise_error(ArgumentError)
    end
  end

  describe CapGun::Mailer do
    describe "deployment_notification" do
      it "builds the correct mail object" do
        capistrano = {
          :cap_gun_email_envelope => {
            :recipients => ["joe@example.com"],
            :from       => "me@example.com"
          }
        }
        presenter = CapGun::Presenter.new(capistrano)
        mail = CapGun::Mailer.deployment_notification(capistrano)
        mail.to.should      == presenter.recipients
        mail.from.should    == [presenter.from] # yes, Mail gem returns an array here
        mail.subject.should == presenter.subject
      end
    end
  end
end
