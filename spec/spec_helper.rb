require 'rspec'
require './spec/support/with_exitstatus'
require 'mocha'
require 'bourne'
require 'cocaine'

RSpec.configure do |config|
  config.mock_with :mocha
  config.include WithExitstatus
end
