shared_examples_for "a command that does not block" do
  it 'does not block if the command output a lot on stderr' do
		cmd = Cocaine::CommandLine.new(
			"ruby",
			"-e '$stdout.puts %{hello}; $stderr.puts %{goodbye}*10_000'",
			:swallow_stderr => false
		)   
    Timeout.timeout(5) do
			cmd.run
		end
		expect(cmd.command_output).to eq "hello\n"
		expect(cmd.command_error_output).to eq "#{"goodbye" * 10_000}\n"
  end
  it 'does not block if the command outputs a lot of data' do
    garbage_file = Tempfile.new("garbage")
    10.times{ garbage_file.write("A" * 1024 * 1024) }

    Timeout.timeout(5) do
      output = subject.call("cat '#{garbage_file.path}'")
      $?.exitstatus.should == 0
      output.output.length.should == 10 * 1024 * 1024
    end

    garbage_file.close
  end
end
