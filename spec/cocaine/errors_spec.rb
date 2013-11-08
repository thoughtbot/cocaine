require 'spec_helper'

describe "When an error happens" do
  it "raises a CommandLineError if the result code from the command isn't expected" do
    cmd = Cocaine::CommandLine.new("convert", "a.jpg b.png", :swallow_stderr => false)
    cmd.stubs(:execute).with("convert a.jpg b.png").returns(:correct_value)
    with_exitstatus_returning(1) do
      lambda do
        cmd.run
      end.should raise_error(Cocaine::CommandLineError)
    end
  end

  it "does not raise if the result code is expected, even if nonzero" do
    cmd = Cocaine::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :expected_outcodes => [0, 1],
                                   :swallow_stderr => false)
    cmd.stubs(:execute).with("convert a.jpg b.png").returns(:correct_value)
    with_exitstatus_returning(1) do
      lambda do
        cmd.run
      end.should_not raise_error
    end
  end

  it "adds command output to exception message if the result code is nonzero" do
    cmd = Cocaine::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :swallow_stderr => false)
    error_output = "Error 315"
    cmd.stubs(:execute).with("convert a.jpg b.png").returns(error_output)
    with_exitstatus_returning(1) do
      begin
        cmd.run
      rescue Cocaine::ExitStatusError => e
        e.message.should =~ /#{error_output}/
      end
    end
  end

  it 'passes error message to the exception when command fails with Errno::ENOENT' do
    cmd = Cocaine::CommandLine.new('test', '')
    cmd.stubs(:execute).with('test').raises(Errno::ENOENT.new("not found"))
    begin
      cmd.run
    rescue Cocaine::CommandNotFoundError => e
      expect(e.message).to eq 'No such file or directory - not found'
    end
  end

  it "should keep result code in #exitstatus" do
    cmd = Cocaine::CommandLine.new("convert")
    cmd.stubs(:execute).with("convert").returns(:correct_value)
    with_exitstatus_returning(1) do
      cmd.run rescue nil
    end
    cmd.exit_status.should == 1
  end

  it "does not blow up if running the command errored before the actual execution" do
    assuming_no_processes_have_been_run
    command = Cocaine::CommandLine.new("echo", ":hello_world")
    command.stubs(:command).raises("An Error")

    lambda{ command.run }.should raise_error("An Error")
    command.exit_status.should be_nil
  end
end
