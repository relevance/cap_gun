begin
  gem 'technicalpickles-echoe'
rescue LoadError => e
  puts "couldn't find the correct version of echoe - please install from forked version on github: http://github.com/technicalpickles/echoe/"
  puts "gem sources -a http://gems.github.com"
  puts "sudo gem install technicalpickles-echoe"
end
  
require 'rubygems'
require 'echoe'
require './lib/cap_gun.rb'

echoe = Echoe.new('cap_gun') do |p|
  p.rubyforge_name = 'thinkrelevance'
  p.author = ["Rob Sanheim", "Relevance"]
  p.email = 'opensource@thinkrelevance.com'
  p.version = CapGun::VERSION
  p.summary = "Bang! You're deployed!"
  p.description = 'Super simple capistrano deployments.'
  p.url = "http://opensource.thinkrelevance.com/wiki/cap_gun"
  p.rdoc_pattern = /^(lib|bin|ext)|txt|rdoc|CHANGELOG|MIT-LICENSE$/
  rdoc_template = `allison --path`.strip << ".rb"
  p.rdoc_template = rdoc_template
  p.test_pattern = 'spec/**/*_spec.rb'
  p.manifest_name = 'manifest.txt'
end

echoe.spec.add_development_dependency "echoe"