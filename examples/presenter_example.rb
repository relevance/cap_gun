require File.join(File.dirname(__FILE__), *%w[example_helper])

describe CapGun::Presenter do 

  describe "scm details" do
  
    it "does nothing if the scm is not git nor subversion" do
      presenter = CapGun::Presenter.new(stub("capistrano", :scm => :mercurial))
      presenter.scm_details.should == nil
    end
  
    it "collects branch and git log details if git is scm" do
      capistrano = {:scm => :git, :branch => "edge"}
      presenter = CapGun::Presenter.new(capistrano)
      presenter.expects(:scm_log).returns("xxxxx")
    
      details = presenter.scm_details
      details.should include("Branch: edge")
      details.should include("xxxxx")
    end
  end

  describe "scm log messages" do
    describe "with git" do
      it "returns N/A if the git log call returns an error" do
        capistrano = {:scm => :git, :previous_revision => "previous-sha", :current_revision => "current-sha" }
        presenter = CapGun::Presenter.new(capistrano)
        presenter.stubs(:`).returns("fatal: Not a git repo")
        presenter.stubs(:exit_code).returns(stub("process status", :success? => false))
        presenter.scm_log_messages.should == "N/A"
      end

      it "calls git log with previous_rev..current_rev" do
        capistrano = {:scm => :git, :previous_revision => "previous-sha", :current_revision => "current-sha" }
        presenter = CapGun::Presenter.new(capistrano)
        presenter.stubs(:exit_code).returns(stub("process status", :success? => true))
        presenter.expects(:`).with(includes("git log previous-sha..current-sha"))
        presenter.scm_log_messages
      end
    end
    describe "with subversion" do
      it "returns N/A if the svn log call returns an error" do
        capistrano = {:scm => :subversion, :previous_revision => "42", :current_revision => "46" }
        presenter = CapGun::Presenter.new(capistrano)
        presenter.stubs(:`).returns("fatal: Not a working copy")
        presenter.stubs(:exit_code).returns(stub("process status", :success? => false))
        presenter.scm_log_messages.should == "N/A"
      end

      it "calls svn log with -r previous_rev+1:current_rev" do
        capistrano = {:scm => :subversion, :previous_revision => "42", :current_revision => "46" }
        presenter = CapGun::Presenter.new(capistrano)
        presenter.stubs(:exit_code).returns(stub("process status", :success? => true))
        presenter.expects(:`).with(includes("svn log -r 43:46"))
        presenter.scm_log_messages
      end
    end
  end

  describe "release time" do
  
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
  
  describe "previous_revision" do
    
    it "returns n/a if not set" do
      CapGun::Presenter.new({}).previous_revision.should == "n/a"
    end
    
    it "returns the previous revision if set" do
      CapGun::Presenter.new({:previous_revision => "100"}).previous_revision.should == "100"
    end
    
  end

end