# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Sebastian Röbke", "Rob Sanheim", "Muness Alrubaie", "Relevance"]
  gem.email         = ["sebastian.roebke@xing.com"]
  gem.description   = %q{Super simple capistrano deployment notifications. Forked from relevance/cap_gun.}
  gem.summary       = %q{Super simple capistrano deployment notifications. Forked from relevance/cap_gun.}
  gem.homepage      = "https://github.com/xing/cap_gun"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.name          = "xing-cap_gun"
  gem.require_paths = ["lib"]
  gem.version       = "0.3.0.pre"

  gem.add_dependency("activesupport")
  gem.add_dependency("actionmailer", ">= 3.0.0")

  gem.add_development_dependency("rake")
  gem.add_development_dependency("rdoc")
  gem.add_development_dependency("rspec")
end
