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

      def call(command, env = {})
        with_modified_environment(env) do
          IO.popen(command, "r") do |pipe|
            pipe.read
          end
        end
      end

      private

      def with_modified_environment(env, &block)
        ClimateControl.modify(env, &block)
      end
    end
  end
end
