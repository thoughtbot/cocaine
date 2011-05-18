$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'cocaine/version'

include_files = ["README*", "LICENSE", "Rakefile", "{lib,spec}/**/*"].map do |glob|
  Dir[glob]
end.flatten
exclude_files = ["**/*.rbc"].map do |glob|
  Dir[glob]
end.flatten

spec = Gem::Specification.new do |s|
  s.name              = "cocaine"
  s.version           = Cocaine::VERSION
  s.author            = "Jon Yurek"
  s.email             = "jyurek@thoughtbot.com"
  s.homepage          = "http://www.thoughtbot.com/projects/cocaine"
  s.description       = "A small library for doing (command) lines"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "A small library for doing (command) lines"
  s.files             = include_files - exclude_files
  s.require_path      = "lib"
  s.test_files        = Dir["spec/**/*_spec.rb"]
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'bourne'
  s.add_development_dependency 'mocha'
end

