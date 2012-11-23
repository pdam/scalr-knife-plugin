# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-scalr/version"

Gem::Specification.new do |s|
  s.name        = "knife-scalr"
  s.version     = Knife::Scalr::VERSION
  s.authors     = ["P Dam"]
  s.email       = ["pdam.2010@gmail.com"]
  s.homepage    = "https://github.com/pdam/knife-scalr"
  s.summary     = %q{A Chef plugin for determining which cookbooks are in use on which nodes of your Chef server or Opscode organization.}
  s.description = %q{Allows you to safely maintain a chef cookbook set by determining which cookbooks are currently in use by nodes (included in node runlists).}

  s.rubyforge_project = "knife-scalr"

  s.files         = `git ls -files `.split("\n")
  s.test_files    = `git ls -files  -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls -files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
