module Cocaine
  class CommandLine
    class << self
      attr_accessor :path, :logger
    end

    def initialize(binary, params = "", options = {})
      @binary            = binary.dup
      @params            = params.dup
      @options           = options.dup
      @logger            = @options.delete(:logger) || self.class.logger
      @swallow_stderr    = @options.delete(:swallow_stderr)
      @expected_outcodes = @options.delete(:expected_outcodes)
      @expected_outcodes ||= [0]
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
        with_modified_path do
          @logger.info("\e[32mCommand\e[0m :: #{command}") if @logger
          output = self.class.send(:'`', command)
        end
      rescue Errno::ENOENT
        raise Cocaine::CommandNotFoundError
      end
      if $?.exitstatus == 127
        raise Cocaine::CommandNotFoundError
      end
      unless @expected_outcodes.include?($?.exitstatus)
        raise Cocaine::ExitStatusError, "Command '#{command}' returned #{$?.exitstatus}. Expected #{@expected_outcodes.join(", ")}"
      end
      output
    end

    private

    def with_modified_path
      begin
        saved_path = ENV['PATH']
        extra_path = [self.class.path].flatten
        ENV['PATH'] = [ENV['PATH'], *extra_path].join(File::PATH_SEPARATOR)
        yield
      ensure
        ENV['PATH'] = saved_path
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
      return "" if string.nil? or string.empty?
      if self.class.unix?
        string.split("'").map{|m| "'#{m}'" }.join("\\'")
      else
        %{"#{string}"}
      end
    end

    def bit_bucket
      self.class.unix? ? "2>/dev/null" : "2>NUL"
    end

    def self.unix?
      (Config::CONFIG['host_os'] =~ /mswin|mingw/).nil?
    end
  end
end
