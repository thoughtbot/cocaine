module Cocaine
  class CommandLine
    class FakeRunner
      
      attr_reader :commands

      def initialize
        @commands = []
      end

      def call(command, env = {})
        commands << [command, env]
        ""
      end

      def ran?(predicate_command)
        @commands.any?{|(command, env)| command =~ Regexp.new(predicate_command) }
      end

    end
  end
end