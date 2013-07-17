require 'rspec'
require 'mocha/api'
require 'bourne'
require 'cocaine'
require 'timeout'
require 'tempfile'
require 'pry'
require 'active_support/buffered_logger'
require 'thread'

Dir[File.dirname(__FILE__) + "/support/**.rb"].each{|support_file| require support_file }

RSpec.configure do |config|
  config.mock_with :mocha
  config.include WithExitstatus
  config.include StubOS
  config.include UnsettingExitstatus
end
