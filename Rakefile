begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "cap_gun"
    gemspec.summary = "Bang! You're deployed."
    gemspec.email = "opensource@thinkrelevance.com"
    gemspec.homepage = "http://github.com/relevance/cap_gun"
    gemspec.description = 'Super simple capistrano deployment notifications.'
    gemspec.authors = ["Rob Sanheim", "Muness Alrubaie", "Relevance"]
    gemspec.rubyforge_project = 'thinkrelevance'
    gemspec.add_development_dependency "spicycode-micronaut"
    gemspec.add_development_dependency "mocha"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
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

  task :default => 'rcov'
rescue LoadError
  puts "Micronaut not available to run tests.  Install it with: sudo gem install spicycode-micronaut -s http://gems.github.com"
end
