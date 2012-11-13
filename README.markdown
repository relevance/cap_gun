# CapGun

## Description

Tell everyone about your releases!  Send email notification after Capistrano deployments!  Rule the world!

Drop your ActionMailer configuration information into your deploy.rb file, configure recipients for the deployment notifications, and setup the callback task.

Setup and configuration are done entirely inside your deploy.rb file to keep it super simple.  Your emails are sent locally from the box performing the deployment, but CapGun queries the server to grab the necessary release info.

## Build status

[![Build Status](https://secure.travis-ci.org/xing/cap_gun.png)](http://travis-ci.org/xing/cap_gun)

## Install

Add this line to your application's `Gemfile`:

```ruby
gem "xing-cap_gun"
```

And then execute:

    $ bundle

Or install it manually:

    $ gem install xing-cap_gun

## Config

In your Capistrano config file (usually `deploy.rb`):

```ruby
require "cap_gun"

# setup action mailer (if not done in rails environment already)
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "example.com",
  :user_name            => "<username>",
  :password             => "<password>",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

# define a repository url to provide a link in the email (optional)
set :repository_url, "https://github.com/example/my-project"

# define the options for the actual emails that go out -- :recipients is the only required option
set :cap_gun_email_envelope, {
  :recipients => %w[joe@example.com, jane@example.com],
  :from       => "project.deployer@example.com"
}

# register email as a callback after restart
after "deploy:restart", "cap_gun:email"
```

Test everything out by running `cap cap_gun:email`.

## Usage

Good news: it just works.

By default CapGun includes info like the user who is deploying and what server its being deployed to.  CapGun is biased for git (patches accepted for other SCMs), so it will include details like your current branch, the revisions since last deployment, the current commit being deployed.

Want to make the notifications even better and explain _why_ you're deploying?
Just include a comment in the cap command like so, and CapGun will add the comment to the email notification.

    $ cap -s comment="fix for bug #303" deploy

## Requirements

* Capistrano 2+
* SMTP server or MTA (mail transport agent) installed locally to send from
* Something to deploy

## Todo & Known Issues

* displays the release times in UTC (Capistrano default) - could be flipped to specified time zone
* some stuff will probably break on windows - patches welcome

## License

(The MIT License)

Copyright (c) 2009 [Relevance, Inc.](http://thinkrelevance.com)

Copyright (c) 2012 [XING AG](http://www.xing.com) ([Devblog](http://devblog.xing.com/))

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
