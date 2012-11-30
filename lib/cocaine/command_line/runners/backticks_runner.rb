# coding: UTF-8

require 'climate_control'

module Cocaine
  class CommandLine
    class BackticksRunner

      def call(command, env = {})
        ClimateControl.modify(env) do
          `#{command}`
        end
      end

    end
  end
end
