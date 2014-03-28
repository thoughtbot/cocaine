# coding: UTF-8

module Cocaine
  class CommandLine
    class PosixRunner
      def self.available?
        require 'posix/spawn'
        true
      rescue LoadError
        false
      end

      def self.supported?
        available? && !Cocaine::CommandLine.java?
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {}, options = {})
        input, output = IO.pipe
        options[:out] = output
        with_modified_environment(env) do
          pid = spawn(env, command, options)
          output.close
          result = ""
          while partial_result = input.read(8192)
            result << partial_result
          end
          waitpid(pid)
          input.close
          result
        end
      end

      private

      def spawn(*args)
        POSIX::Spawn.spawn(*args)
      end

      def waitpid(pid)
        Process.waitpid(pid)
      end

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end

    end
  end
end
