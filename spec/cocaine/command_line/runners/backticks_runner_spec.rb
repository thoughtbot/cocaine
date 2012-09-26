require 'spec_helper'

describe Cocaine::CommandLine::BackticksRunner do
  it_behaves_like 'a command that does not block'

  it 'runs the command given' do
    subject.call("echo hello").should == "hello\n"
  end

  it 'modifies the environment and runs the command given' do
    subject.call("echo $yes", {"yes" => "no"}).should == "no\n"
  end

  it 'sets the exitstatus when a command completes' do
    subject.call("ruby -e 'exit 0'")
    $?.exitstatus.should == 0
    subject.call("ruby -e 'exit 5'")
    $?.exitstatus.should == 5
  end
end
