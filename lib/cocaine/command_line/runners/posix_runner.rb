# coding: UTF-8

module Cocaine
  class CommandLine
    class PosixRunner
      if Cocaine::CommandLine.posix_spawn_available?

        def call(command, env = {})
          input, output = IO.pipe
          pid = spawn(env, command, :out => output)
          output.close
          result = ""
          while partial_result = input.read(8192)
            result << partial_result
          end
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
