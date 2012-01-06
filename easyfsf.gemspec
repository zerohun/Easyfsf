# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "easyfsf/version"

Gem::Specification.new do |s|
  s.name        = "easyfsf"
  s.version     = Easyfsf::VERSION
  s.authors     = ["Younghun Choi"]
  s.email       = ["choi0hun@gmail.com"]
  s.homepage    = "http://zerohun.wordpress.com/2012/01/06/easyfsf/"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "easyfsf"


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rails", "~> 3.0.0"
  s.add_development_dependency "rspec"
end
