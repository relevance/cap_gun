Gem::Specification.new do |s|
  s.name = %q{cap_gun}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new("= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rob Sanheim, Relevance"]
  s.date = %q{2008-07-04}
  s.description = %q{Super simple capistrano deployments.}
  s.email = %q{opensource@thinkrelevance.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/cap_gun.rb", "MIT-LICENSE", "README.rdoc"]
  s.files = ["cap_gun.gemspec", "CHANGELOG", "init.rb", "install.rb", "lib/cap_gun.rb", "manifest.txt", "MIT-LICENSE", "Rakefile", "README.rdoc", "spec/cap_gun_spec.rb", "tasks/cap_bot_tasks.rake", "vendor/action_mailer_tls/init.rb", "vendor/action_mailer_tls/lib/smtp_tls.rb", "vendor/action_mailer_tls/README", "vendor/action_mailer_tls/sample/mailer.yml.sample", "vendor/action_mailer_tls/sample/smtp_gmail.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://opensource.thinkrelevance.com/wiki/cap_gun}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Cap_gun", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{thinkrelevance}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Bang! You're deployed!}
  s.test_files = ["spec/cap_gun_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<echoe>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<echoe>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<echoe>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
