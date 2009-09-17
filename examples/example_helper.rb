ENV["RAILS_ENV"] = "test"
require 'net/smtp'
require "mocha"
require 'micronaut'
require File.join(File.dirname(__FILE__), *%w[.. lib cap_gun])

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

Micronaut.configure do |config|
  config.mock_with :mocha
  config.formatter = :documentation
  config.color_enabled = true
  config.filter_run :options => { :focused => true }
end