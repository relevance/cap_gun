# remove the warn flag, otherwise we get all warnings when we load Rails stuff
ENV['RUBY_FLAGS'] = "-I#{%w(lib ext bin test).join(File::PATH_SEPARATOR)}"

require 'rubygems'
require 'echoe'
require './lib/cap_gun.rb'

hoe = Echoe.new('cap_gun') do |p|
  p.version = CapGun::VERSION
  p.rubyforge_name = 'thinkrelevance'
  p.author = ["Rob Sanheim", "Relevance"]
  p.email = 'opensource@thinkrelevance.com'
  p.summary = "Bang! You're deployed!"
  p.description = ''#p.paragraphs_of('README.rdoc', 2..5).join("\n\n")
  p.url = "http://opensource.thinkrelevance.com/wiki/cap_gun"
  p.changes = 'foo'
  p.rdoc_pattern = /^(lib|bin|ext)|txt|rdoc$/
  p.rdoc_template = 'allison'
  p.test_pattern = 'spec/**/*_spec.rb'
  p.manifest_name = 'manifest.txt'
end

# Override RDoc to use allison template, and also use our .rdoc README as the main page instead of the default README.txt
Rake::RDocTask.new(:docs) do |rd|
  gem "allison"
  gem "markaby"
  rd.main = "README.rdoc"
  rd.options << '-d' if RUBY_PLATFORM !~ /win32/ and `which dot` =~ /\/dot/ and not ENV['NODOT']
  rd.rdoc_dir = 'doc'
  files = hoe.spec.files.grep(hoe.rdoc_pattern)
  files -= ['Manifest.txt']
  rd.rdoc_files.push(*files)

  title = "#{hoe.name}-#{hoe.version} Documentation"
  rdoc_template = `allison --path`.strip << ".rb"
  rd.template = rdoc_template
  rd.options << "-t #{title}"
  rd.options << '--line-numbers' << '--inline-source'
end