# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "env_specific_migration/version"

Gem::Specification.new do |s|
  s.name        = "env_specific_migration"
  s.version     = EnvSpecificMigration::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Gulics"]
  s.email       = ["sgulics@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Allows you to create Rails migrations that will only run in the specified environment}
  s.description = %q{Allows you to create Rails migrations that will only run in the specified environment}

  s.rubyforge_project = "env_specific_migration"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
