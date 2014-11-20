# coding: UTF-8

require 'climate_control'

module Cocaine
  class CommandLine
    class BackticksRunner
      def self.supported?
        true
      end

      def supported?
        self.class.supported?
      end

      def call(command, env = {}, options = {})
        with_modified_environment(env) do
          `#{encoded_command(command)}`
        end
      end

      private

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end

      def encoded_command(command)
        if Cocaine::CommandLine.java?
          command.encode('ASCII-8BIT')
        else
          command
        end
      end

    end
  end
end
