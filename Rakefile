require "bundler/gem_tasks"
require "rdoc/task"
require "rspec/core/rake_task"

Rake::RDocTask.new do |t|
  t.title = "cap_gun"
  t.rdoc_dir = "rdoc"
  t.rdoc_files.include("README*")
  t.rdoc_files.include("lib/**/*.rb")
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = "--color"
end

task :default => :spec
