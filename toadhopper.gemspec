# -*- encoding: utf-8 -*-

$: << File.expand_path('../lib', __FILE__)

require 'toadhopper'


Gem::Specification.new do |s|
  s.name        = 'toadhopper'
  s.version     = Toadhopper::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tim Lucas', 'Samuel Tesla', 'Corey Donohoe', 'Andre Arko', 'Theo Hultberg']
  s.email       = ['t.lucas@toolmantim.com']
  s.homepage    = 'http://github.com/toolmantim/toadhopper'
  s.summary     = %q{Post error notifications to Airbrake}
  s.description = %q{A base library for Airbrake error reporting}

  s.rubyforge_project = 'toadhopper'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.extra_rdoc_files  = ['README.md', 'LICENSE']
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'fakeweb'
end
