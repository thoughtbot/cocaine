module Cocaine
  class CommandLine
    class << self
      attr_accessor :logger

      def path
        @supplemental_path
      end
      def path=(supplemental_path)
        @supplemental_path = supplemental_path
        @supplemental_environment ||= {}
        @supplemental_environment['PATH'] = [ENV['PATH'], *supplemental_path].join(File::PATH_SEPARATOR)
      end

      def posix_spawn_available?
        @posix_spawn_available ||= begin
          require 'posix/spawn'
          true
        rescue LoadError => e
          false
        end
      end

      def environment
        @supplemental_environment ||= {}
      end
    end
    @environment = {}

    attr_reader :exit_status, :runner

    def initialize(binary, params = "", options = {})
      @binary            = binary.dup
      @params            = params.dup
      @options           = options.dup
      @logger            = @options.delete(:logger) || self.class.logger
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes)
      @expected_outcodes ||= [0]
      @runner            = best_runner
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
        @logger.info("\e[32mCommand\e[0m :: #{command}") if @logger
        output = execute(command)
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

    def execute(command)
      runner.call(command, self.class.environment)
    end

    def best_runner
      return PosixRunner.new   if self.class.posix_spawn_available?
      return ProcessRunner.new if Process.respond_to?(:spawn)
      BackticksRunner.new
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
