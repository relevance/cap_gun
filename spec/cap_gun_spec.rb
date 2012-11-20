require "spec_helper"

describe CapGun do
  describe "mail settings" do
    it "raises if don't have a cap gun email envelope" do
      capistrano = double(
        :cap_gun_action_mailer_config => {},
        :exists? => false
      ).as_null_object

      lambda {
        CapGun::Mailer.load_mailer_config(capistrano)
      }.should raise_error(ArgumentError)
    end

    it "raises if we don't have at least one recipient" do
      capistrano = double(
        :cap_gun_action_mailer_config => {},
        :cap_gun_email_envelope => {}
      ).as_null_object

      lambda {
        CapGun::Mailer.load_mailer_config(capistrano)
      }.should raise_error(ArgumentError)

      capistrano = double(
        :cap_gun_action_mailer_config => {},
        :cap_gun_email_envelope => {
          :recipients => []
        }
      ).as_null_object

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
