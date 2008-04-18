# remove the warn flag, otherwise we get all warnings when we load Rails stuff
# ENV['RUBY_FLAGS'] = "-I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}"

require 'rubygems'
require 'echoe'
require './lib/cap_gun.rb'

hoe = Echoe.new('cap_gun') do |p|
  p.rubyforge_name = 'thinkrelevance'
  p.author = ["Rob Sanheim", "Relevance"]
  p.email = 'opensource@thinkrelevance.com'
  p.version = CapGun::VERSION
  p.summary = "Bang! You're deployed!"
  p.description = 'Super simple capistrano deployments.'
  p.url = "http://opensource.thinkrelevance.com/wiki/cap_gun"
  p.changes = 'foo'
  p.rdoc_pattern = /^(lib|bin|ext)|txt|rdoc$/
  rdoc_template = `allison --path`.strip << ".rb"
  p.rdoc_template = rdoc_template
  p.test_pattern = 'spec/**/*_spec.rb'
  p.manifest_name = 'manifest.txt'
end