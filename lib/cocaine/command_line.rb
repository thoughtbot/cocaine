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
      @runner            = best_runner
      @logger            = @options.delete(:logger) || self.class.logger
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes) || [0]
      @environment       = @options.delete(:environment) || {}
    end

    def command(interpolations = {})
      cmd = []
      cmd << @binary
      cmd << interpolate(@params, interpolations)
      cmd << bit_bucket if @swallow_stderr
      cmd.join(" ").strip
    end

    def run(interpolations = {})
      output = ''
      begin
        @logger.info("\e[32mCommand\e[0m :: #{command}") if @logger
        output = execute(command(interpolations))
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
      runner.call(command, environment)
    end

    def environment
      self.class.environment.merge(@environment)
    end

    def best_runner
      return PosixRunner.new   if self.class.posix_spawn_available?
      return ProcessRunner.new if Process.respond_to?(:spawn)
      BackticksRunner.new
    end

    def interpolate(pattern, interpolations)
      interpolations.inject(pattern) do |command_string, (key, value)|
        command_string.gsub(/:\{?#{key}\}?/) { shell_quote(value) }
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
