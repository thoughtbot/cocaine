module Cocaine
  class CommandLine
    class ProcessRunner
      if Process.respond_to?(:spawn)

        def call(command, env = {})
          input, output = IO.pipe
          pid = spawn(env, command, :out => output)
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
          Process.waitpid(pid)
        end

      end
    end
  end
end

