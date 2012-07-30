# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'jsontrim'

Gem::Specification.new do |s|
  s.name = %q{jsontrim}
  s.version = JSONTrim::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Levin Alexander"]
  s.description = %q{remove unimportant elements from a json object}
  s.email = %q{mail@levinalex.net}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.homepage = %q{http://github.com/levinalex/lis}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{remove unimportant elements from a json object}

  s.add_development_dependency("shoulda", "~> 3.1")
  s.add_development_dependency("json")
  s.add_development_dependency("rake")
end

