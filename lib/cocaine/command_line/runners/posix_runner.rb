module Cocaine
  class CommandLine
    class PosixRunner
      if Cocaine::CommandLine.posix_spawn_available?

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
          POSIX::Spawn.spawn(*args)
        end

        def waitpid(pid)
          Process.waitpid(pid)
        end

      end
    end
  end
end
