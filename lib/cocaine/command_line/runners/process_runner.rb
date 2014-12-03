# coding: UTF-8

module Cocaine
  class CommandLine
    class ProcessRunner
      def self.available?
        Process.respond_to?(:spawn)
      end

      def self.supported?
        available? && !OS.java?
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {}, options = {})
        input, output = IO.pipe
        options[:out] = output
        pid = spawn(env, command, options)
        output.close
        result = input.read
        waitpid(pid)
        input.close
        result
      end

      private

      def spawn(*args)
        Process.spawn(*args)
      end

      def waitpid(pid)
        Process.waitpid(pid)
      rescue Errno::ECHILD
        # In JRuby, waiting on a finished pid raises.
      end

    end
  end
end
