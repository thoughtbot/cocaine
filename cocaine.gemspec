$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'cocaine/version'

Gem::Specification.new do |s|
  s.name              = "cocaine"
  s.version           = Cocaine::VERSION.dup
  s.platform          = Gem::Platform::RUBY
  s.author            = "Jon Yurek"
  s.email             = "jyurek@thoughtbot.com"
  s.homepage          = "http://github.com/thoughtbot/cocaine"
  s.summary           = "A small library for doing (command) lines"
  s.description       = "A small library for doing (command) lines"
  s.license           = "MIT"

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {test,spec,features}/*`.split("\0")
  s.executables   = `git ls-files -z -- bin/*`.split("\0").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('climate_control', '>= 0.0.3', '< 1.0')
  s.add_development_dependency('rspec')
  s.add_development_dependency('bourne')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rake')
  s.add_development_dependency('activesupport', ">= 3.0.0", "< 5.0")
  s.add_development_dependency('pry')
end

