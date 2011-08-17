require 'rspec'
require './spec/support/with_exitstatus'
require './spec/support/stub_os'
require 'mocha'
require 'bourne'
require 'cocaine'

RSpec.configure do |config|
  config.mock_with :mocha
  config.include WithExitstatus
  config.include StubOS
end
