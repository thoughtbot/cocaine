# coding: UTF-8

module Cocaine
  class CommandLine
    class PopenRunner
      def call(command, env = {}, options = {})
        with_modified_environment(env) do
          IO.popen(command, "r", options) do |pipe|
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
