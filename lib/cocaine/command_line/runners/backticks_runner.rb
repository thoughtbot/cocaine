module Cocaine
  class CommandLine
    class BackticksRunner

      def call(command, env = {})
        with_modified_environment(env) do
          `#{command}`
        end
      end

      private

      def with_modified_environment(env)
        begin
          saved_env = ENV.to_hash
          ENV.update(env)
          yield
        ensure
          ENV.update(saved_env)
        end
      end

    end
  end
end
