# coding: UTF-8

module Cocaine
  class CommandLine
    class PopenRunner
      def self.supported?
        true
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {}, options = {})
        with_modified_environment(env) do
          IO.popen(env_command(command), "r", options) do |pipe|
            pipe.read
          end
        end
      end

      private

      def env_command(command)
        if Cocaine::CommandLine.java?
          "env #{command}"
        else
          command
        end
      end

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end
    end
  end
end
