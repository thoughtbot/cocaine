# coding: UTF-8

module Cocaine
  class CommandLine
    class ProcessRunner
      if Process.respond_to?(:spawn)

        def call(command, env = {}, options = {})
          input, output = IO.pipe
          options[:out] = output
          pid = spawn(env, command, options)
          output.close
          result = input.read
          waitpid(pid)
          result
        end

        private

        def spawn(*args)
          Process.spawn(*args)
        end

        def waitpid(pid)
          begin
            Process.waitpid(pid)
          rescue Errno::ECHILD => e
            # In JRuby, waiting on a finished pid raises.
          end
        end

      end
    end
  end
end

