require 'rspec'
require 'mocha'
require 'bourne'
require 'cocaine'
require 'timeout'
require 'tempfile'

Dir[File.dirname(__FILE__) + "/support/**.rb"].each{|support_file| require support_file }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include WithExitstatus
  config.include StubOS
end
