# CapGun
  
## DESCRIPTION

Tell everyone about your releases!  Send email notification after Capistrano deployments!  Rule the world!

Drop your ActionMailer configuration information into your deploy.rb file, configure recipients for the deployment notifications, and setup the callback task.

Setup and configuration are done entirely inside your deploy.rb file to keep it super simple.  Your emails are sent locally from the box performing the deployment, but CapGun queries the server to grab the necessary release info.

This even includes the Net::SMTP TLS hack inside as a vendored dependancy to allow super easy email sending without setting up an MTA.

## CONFIG

In your Capistrano config file (usually deploy.rb):

    # require cap_gun (the path will depend on where you unpacked or if you are just using it as a gem)
    require 'vendor/plugins/cap_gun/lib/cap_gun' # typical Rails vendor/plugins location
    
    # setup action mailer with a hash of options
    set :cap_gun_action_mailer_config, {
      :address => "smtp.gmail.com",
      :port => 587,
      :user_name => "[YOUR_USERNAME]@gmail.com",
      :password => "[YOUR_PASSWORD]",
      :authentication => :plain 
    }

    # define the options for the actual emails that go out -- :recipients is the only required option
    set :cap_gun_email_envelope, { 
      :from => "project.deployer@example.com", # Note, don't use the form "Someone project.deploy@example.com" as it'll blow up with ActionMailer 2.3+
      :recipients => %w[joe@example.com, jane@example.com] 
    }
    
    # register email as a callback after restart
    after "deploy:restart", "cap_gun:email"
    
    # Test everything out by running "cap cap_gun:email"

## USAGE

Good news: it just works.  

By default CapGun includes info like the user who is deploying and what server its being deployed to.  CapGun is biased for git (patches accepted for other SCMs), so it will include details like your current branch, the revisions since last deployment, the current commit being deployed.

Want to make the notifications even better and explain _why_ you're deploying?
Just include a comment in the cap command like so, and CapGun will add the comment to the email notification.

    cap -s comment="fix for bug #303" deploy

## REQUIREMENTS

* Capistrano 2+
* A Gmail account to send from, or an MTA (mail transport agent) installed locally to send from
* Something to deploy

## TODO & KNOWN ISSUES

* displays the release times in UTC (Capistrano default) - could be flipped to specified time zone
* some stuff will probably break on windows - patches welcome

## INSTALL

* `sudo gem install cap_gun`  and gem unpack into your vendor/plugins
* or just grab the tarball from github (see below)

## URLS

* Log bugs, issues, and suggestions at GitHub: http://github.com/relevance/cap_gun/issues
* View source: http://github.com/relevance/cap_gun
* SDocs: http://relevance.github.com/cap_gun/

== LICENSE

(The MIT License)

Copyright (c) 2009 Relevance, Inc. - http://thinkrelevance.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 
 
 
