# coding: UTF-8

module Cocaine
  class CommandLine
    class PosixRunner
      def self.available?
        begin
          require 'posix/spawn'
          true
        rescue LoadError => e
          false
        end
      end

      def self.supported?
        available? && !Cocaine::CommandLine.java?
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {})
        input, output = IO.pipe
        pid = spawn(env, command, :out => output)
        output.close
        result = ""
        while partial_result = input.read(8192)
          result << partial_result
        end
        waitpid(pid)
        input.close
        result
      end

      private

      def spawn(*args)
        POSIX::Spawn.spawn(*args)
      end

      def waitpid(pid)
        Process.waitpid(pid)
      end

    end
  end
end
