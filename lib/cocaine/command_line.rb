module Cocaine
  class CommandLine
    # Check for posix-spawn gem. If it is available it will prevent the invoked processes
    # from getting a copy of the ruby heap which can lead to significant performance gains.
    begin
     require 'posix/spawn'
    rescue LoadError => e
      # posix-spawn gem not available
    end
    
    class << self
      attr_accessor :path, :logger, :environment
    end
    @environment = {}

    attr_reader :exit_status

    def initialize(binary, params = "", options = {})
      @binary            = binary.dup
      @params            = params.dup
      @options           = options.dup
      @logger            = @options.delete(:logger) || self.class.logger
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes)
      @expected_outcodes ||= [0]
      extend(POSIX::Spawn) if defined?(POSIX::Spawn)
    end

    def command
      cmd = []
      cmd << @binary
      cmd << interpolate(@params, @options)
      cmd << bit_bucket if @swallow_stderr
      cmd.join(" ").strip
    end

    def run
      output = ''
      begin
        set_modified_path
        with_modified_environment do
          @logger.info("\e[32mCommand\e[0m :: #{command}") if @logger
          output = send(:'`', command)
        end
      rescue Errno::ENOENT
        raise Cocaine::CommandNotFoundError
      ensure
        @exit_status = $?.exitstatus
      end
      if $?.exitstatus == 127
        raise Cocaine::CommandNotFoundError
      end
      unless @expected_outcodes.include?($?.exitstatus)
        raise Cocaine::ExitStatusError, "Command '#{command}' returned #{$?.exitstatus}. Expected #{@expected_outcodes.join(", ")}"
      end
      output
    end

    def unix?
      (RbConfig::CONFIG['host_os'] =~ /mswin|mingw/).nil?
    end

    private
    
    def with_modified_environment
      begin
        # Save current environment
        saved_env = ENV.select {|k,v| self.class.environment.key?(k)}
        # Update environment
        ENV.update(self.class.environment)
        yield
      ensure
        # Restore old environment
        ENV.update(saved_env)
      end
    end

    def set_modified_path
      unless self.class.path.nil? or self.class.path == ''
        extra_path = [self.class.path].flatten
        self.class.environment['PATH'] = [ENV['PATH'], *extra_path].join(File::PATH_SEPARATOR)
      end
    end

    def interpolate(pattern, vars)
      # interpolates :variables and :{variables}
      pattern.gsub(%r#:(?:\w+|\{\w+\})#) do |match|
        key = match[1..-1]
        key = key[1..-2] if key[0,1] == '{'
        if invalid_variables.include?(key)
          raise InterpolationError,
            "Interpolation of #{key} isn't allowed."
        end
        interpolation(vars, key) || match
      end
    end

    def invalid_variables
      %w(expected_outcodes swallow_stderr logger)
    end

    def interpolation(vars, key)
      if vars.key?(key.to_sym)
        shell_quote(vars[key.to_sym])
      end
    end

    def shell_quote(string)
      return "" if string.nil?
      if unix?
        if string.empty?
          "''"
        else
          string.split("'").map{|m| "'#{m}'" }.join("\\'")
        end
      else
        %{"#{string}"}
      end
    end

    def bit_bucket
      unix? ? "2>/dev/null" : "2>NUL"
    end
  end
end
