require 'rubygems'
gem 'echoe', '~> 3.0'
require 'echoe'
require './lib/cap_gun.rb'

echoe = Echoe.new('cap_gun') do |p|
  p.rubyforge_name = 'thinkrelevance'
  p.author = ["Rob Sanheim", "Relevance", "Muness Alrubaie"]
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