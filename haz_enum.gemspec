# -*- encoding: utf-8 -*-
require File.join(File.dirname(__FILE__), *%w[lib version])

Gem::Specification.new do |s|
  s.name = %q{haz_enum}
  s.version = HazEnum::VERSION
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "haz_enum"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["thyphoon"]
  s.date = %q{2011-05-25}
  s.description = %q{use has_set and has_enum in your ActiveRecord models if you want to have one (has_enum) value from a defined enumeration or more (has_set))}
  s.email = %q{andi@galaxycats.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = `git ls-files`.split("\n")

  s.homepage = %q{http://github.com/galaxycats/haz_enum}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{has_set and has_enum for ActiveRecord}
  s.test_files = `git ls-files -- spec/*`.split("\n")

  s.add_runtime_dependency(%q<activerecord>, [">= 2.3.0"])
  s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
  s.add_development_dependency(%q<renum>, ["~> 1.3.1"])
  s.add_development_dependency(%q<rake>, ["~> 10.0.3"])
  s.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
end

