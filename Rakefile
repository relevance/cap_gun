begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cap_gun"
    gemspec.summary = "Bang! You're deployed."
    gemspec.email = "opensource@thinkrelevance.com"
    gemspec.homepage = "http://github.com/relevance/cap_gun"
    gemspec.description = 'Super simple capistrano deployment notifications.'
    gemspec.authors = ["Rob Sanheim", "Muness Alrubaie", "Relevance"]
    gemspec.add_dependency 'activesupport'
    gemspec.add_dependency 'actionmailer'
    gemspec.add_development_dependency "micronaut"
    gemspec.add_development_dependency "mocha"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

begin 
  require 'micronaut/rake_task'
  Micronaut::RakeTask.new(:examples) do |examples|
    examples.pattern = 'examples/**/*_example.rb'
    examples.ruby_opts << '-Ilib -Iexamples'
  end

  Micronaut::RakeTask.new(:rcov) do |examples|
    examples.pattern = 'examples/**/*_example.rb'
    examples.rcov_opts = %[-Ilib -Iexamples --exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage]
    examples.rcov = true
  end
end

if RUBY_VERSION =~ /1.8/ 
  task :default => [:check_dependencies, :rcov]
else
  task :default => [:check_dependencies, :examples]
end

begin
  %w{sdoc sdoc-helpers rdiscount}.each { |name| gem name }
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cap_gun #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
