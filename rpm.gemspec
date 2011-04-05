# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rpm/version"

Gem::Specification.new do |s|
  s.name        = "rpm"
  s.version     = RPM::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Colin MacKenzie IV"]
  s.email       = ["sinisterchipmunk@gmail.com"]
  s.homepage    = "http://thoughtsincomputation.com"
  s.summary     = %q{Generates RPM packages out of a gem or Rails project}
  s.description = %q{Generates RPM packages out of a gem or Rails project}

  s.add_dependency "thor"

  s.rubyforge_project = "rpm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
