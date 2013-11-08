require 'spec_helper'

describe "When picking a Runner" do
  it "uses the BackticksRunner by default" do
    Cocaine::CommandLine::ProcessRunner.stubs(:supported?).returns(false)
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Cocaine::CommandLine.new("echo", "hello")

    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "uses the ProcessRunner on 1.9 and it's available" do
    Cocaine::CommandLine::ProcessRunner.stubs(:supported?).returns(true)
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(false)

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::ProcessRunner
  end

  it "uses the PosixRunner if the PosixRunner is available" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::PosixRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks all the time" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)
    Cocaine::CommandLine.runner = Cocaine::CommandLine::BackticksRunner.new

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "uses the BackticksRunner if the PosixRunner is available, but we told it to use Backticks" do
    Cocaine::CommandLine::PosixRunner.stubs(:supported?).returns(true)

    cmd = Cocaine::CommandLine.new("echo", "hello", :runner => Cocaine::CommandLine::BackticksRunner.new)
    cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
  end

  it "can go into 'Fake' mode" do
    Cocaine::CommandLine.fake!

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should eq Cocaine::CommandLine::FakeRunner
  end

  it "can turn off Fake mode" do
    Cocaine::CommandLine.fake!
    Cocaine::CommandLine.unfake!

    cmd = Cocaine::CommandLine.new("echo", "hello")
    cmd.runner.class.should_not eq Cocaine::CommandLine::FakeRunner
  end

  it "can use a FakeRunner even if not in Fake mode" do
    Cocaine::CommandLine.unfake!

    cmd = Cocaine::CommandLine.new("echo", "hello", :runner => Cocaine::CommandLine::FakeRunner.new)
    cmd.runner.class.should eq Cocaine::CommandLine::FakeRunner
  end
end
