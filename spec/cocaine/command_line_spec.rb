require 'spec_helper'

describe Cocaine::CommandLine do
  before do
    Cocaine::CommandLine.path = nil
    on_unix! # Assume we're on unix unless otherwise specified.
  end

  it "takes a command and parameters and produces a Bash command line" do
    cmd = Cocaine::CommandLine.new("convert", "a.jpg b.png", :swallow_stderr => false)
    cmd.command.should == "convert a.jpg b.png"
  end

  it "specifies the $PATH where the command can be found" do
    Cocaine::CommandLine.path = "/path/to/command/dir"
    cmd = Cocaine::CommandLine.new("ruby", "-e 'puts ENV[%{PATH}]'")
    cmd.command.should == "ruby -e 'puts ENV[%{PATH}]'"
    output = cmd.run
    output.should match(%r{/path/to/command/dir})
  end

  it "specifies more than one path where the command can be found" do
    Cocaine::CommandLine.path = ["/path/to/command/dir", "/some/other/path"]
    cmd = Cocaine::CommandLine.new("ruby", "-e 'puts ENV[%{PATH}]'")
    output = cmd.run
    output.should match(%r{/path/to/command/dir})
    output.should match(%r{/some/other/path})
  end

  it "temporarily changes specified environment variables" do
    Cocaine::CommandLine.environment['TEST'] = 'Hello, world!'
    cmd = Cocaine::CommandLine.new("ruby", "-e 'puts ENV[%{TEST}]'")
    output = cmd.run
    output.should match(%r{Hello, world!})
  end

  it 'changes environment variables for the command line' do
    Cocaine::CommandLine.environment['TEST'] = 'Hello, world!'
    cmd = Cocaine::CommandLine.new("ruby",
                                   "-e 'puts ENV[%{TEST}]'",
                                   :environment => {'TEST' => 'Hej hej'})
    output = cmd.run
    output.should match(%r{Hej hej})
  end

  it 'passes the existing environment variables through to the runner' do
    command = Cocaine::CommandLine.new('echo', '$HOME')
    output = command.run
    output.chomp.should_not == ''
  end

  it "can interpolate quoted variables into the command line's parameters" do
    cmd = Cocaine::CommandLine.new("convert",
                                   ":one :{two}",
                                   :swallow_stderr => false)

    command_string = cmd.command(:one => "a.jpg", :two => "b.png")
    command_string.should == "convert 'a.jpg' 'b.png'"
  end

  it "interpolates when running a command" do
    command = Cocaine::CommandLine.new("echo", ":hello_world")
    command.run(:hello_world => "Hello, world").should match(/Hello, world/)
  end

  it "quotes command line options differently if we're on windows" do
    on_windows!
    cmd = Cocaine::CommandLine.new("convert",
                                   ":one :{two}",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "a.jpg", :two => "b.png")
    command_string.should == 'convert "a.jpg" "b.png"'
  end

  it "can quote and interpolate dangerous variables" do
    cmd = Cocaine::CommandLine.new("convert",
                                   ":one :two",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "`rm -rf`.jpg", :two => "ha'ha.png")
    command_string.should == "convert '`rm -rf`.jpg' 'ha'\\''ha.png'"
  end

  it "can quote and interpolate dangerous variables even on windows" do
    on_windows!
    cmd = Cocaine::CommandLine.new("convert",
                                   ":one :two",
                                   :swallow_stderr => false)
    command_string = cmd.command(:one => "`rm -rf`.jpg", :two => "ha'ha.png")
    command_string.should == %{convert "`rm -rf`.jpg" "ha'ha.png"}
  end

  it "quotes blank values into the command line's parameters" do
    cmd = Cocaine::CommandLine.new("curl",
                                   "-X POST -d :data :url",
                                   :swallow_stderr => false)
    command_string = cmd.command(:data => "", :url => "http://localhost:9000")
    command_string.should == "curl -X POST -d '' 'http://localhost:9000'"
  end

  it "allows colons in parameters" do
    cmd = Cocaine::CommandLine.new("convert", "'a.jpg' xc:black 'b.jpg'", :swallow_stderr => false)
    cmd.command.should == "convert 'a.jpg' xc:black 'b.jpg'"
  end

  it "can redirect stderr to the bit bucket if requested" do
    cmd = Cocaine::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :swallow_stderr => true)

    cmd.command.should == "convert a.jpg b.png 2>/dev/null"
  end

  it "can redirect stderr to the bit bucket on windows" do
    on_windows!
    cmd = Cocaine::CommandLine.new("convert",
                                   "a.jpg b.png",
                                   :swallow_stderr => true)

    cmd.command.should == "convert a.jpg b.png 2>NUL"
  end

  it "runs the command it's given and return the output" do
    cmd = Cocaine::CommandLine.new("convert", "a.jpg b.png", :swallow_stderr => false)
    cmd.stubs(:execute).with("convert a.jpg b.png").returns(:correct_value)
    with_exitstatus_returning(0) do
      cmd.run.should == :correct_value
    end
  end

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

  it "should keep result code in #exitstatus" do
    cmd = Cocaine::CommandLine.new("convert")
    cmd.stubs(:execute).with("convert").returns(:correct_value)
    with_exitstatus_returning(1) do
      cmd.run rescue nil
    end
    cmd.exit_status.should == 1
  end

  it "detects that the system is unix" do
    Cocaine::CommandLine.new("convert").should be_unix
  end

  it "detects that the system is windows" do
    on_windows!
    Cocaine::CommandLine.new("convert").should_not be_unix
  end

  it "detects that the system is windows (mingw)" do
    on_mingw!
    Cocaine::CommandLine.new("convert").should_not be_unix
  end

  it "colorizes the output to a tty" do
    logger = FakeLogger.new(:tty => true)
    Cocaine::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    logger.entries.should include("\e[32mCommand\e[0m :: echo 'Logging!' 'bar'")
  end

  it 'can still take something that does not respond to tty as a logger' do
    output_buffer = StringIO.new
    logger = ActiveSupport::BufferedLogger.new(output_buffer)
    logger.should_not respond_to(:tty?)
    Cocaine::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    output_buffer.rewind
    output_buffer.read.should == "Command :: echo 'Logging!' 'bar'\n"
  end

  it "logs the command to a supplied logger" do
    logger = FakeLogger.new
    Cocaine::CommandLine.new("echo", "'Logging!' :foo", :logger => logger).run(:foo => "bar")
    logger.entries.should include("Command :: echo 'Logging!' 'bar'")
  end

  it "logs the command to a default logger" do
    Cocaine::CommandLine.logger = FakeLogger.new
    Cocaine::CommandLine.new("echo", "'Logging!'").run
    Cocaine::CommandLine.logger.entries.should include("Command :: echo 'Logging!'")
  end

  it "is fine if no logger is supplied" do
    Cocaine::CommandLine.logger = nil
    cmd = Cocaine::CommandLine.new("echo", "'Logging!'", :logger => nil)
    lambda { cmd.run }.should_not raise_error
  end

  describe "command execution" do
    it "uses the BackticksRunner by default" do
      Process.stubs(:respond_to?).with(:spawn).returns(false)
      Cocaine::CommandLine.stubs(:posix_spawn_available?).returns(false)

      cmd = Cocaine::CommandLine.new("echo", "hello")
      cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
    end

    it "uses the ProcessRunner on 1.9 and it's available" do
      Process.stubs(:respond_to?).with(:spawn).returns(true)
      Cocaine::CommandLine.stubs(:posix_spawn_available?).returns(false)

      cmd = Cocaine::CommandLine.new("echo", "hello")
      cmd.runner.class.should == Cocaine::CommandLine::ProcessRunner
    end

    it "uses the PosixRunner if the posix-spawn gem is available" do
      Cocaine::CommandLine.stubs(:posix_spawn_available?).returns(true)

      cmd = Cocaine::CommandLine.new("echo", "hello")
      cmd.runner.class.should == Cocaine::CommandLine::PosixRunner
    end

    it "uses the BackticksRunner if the posix-spawn gem is available, but we told it to use Backticks all the time" do
      Cocaine::CommandLine.stubs(:posix_spawn_available?).returns(true)
      Cocaine::CommandLine.runner = Cocaine::CommandLine::BackticksRunner.new

      cmd = Cocaine::CommandLine.new("echo", "hello")
      cmd.runner.class.should == Cocaine::CommandLine::BackticksRunner
    end

    it "uses the BackticksRunner if the posix-spawn gem is available, but we told it to use Backticks" do
      Cocaine::CommandLine.stubs(:posix_spawn_available?).returns(true)

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
end
