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
        windows_command(command) || java_command(command) || default_command(command)
      end

      def windows_command(command)
        if OS.windows?
          command
        end
      end

      def java_command(command)
        if OS.java?
          "env #{command}"
        end
      end

      def default_command(command)
        command
      end

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end
    end
  end
end
