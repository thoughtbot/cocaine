# Cocaine [![Build Status](https://secure.travis-ci.org/thoughtbot/cocaine.png)](http://travis-ci.org/thoughtbot/cocaine)

A small library for doing (command) lines.

[API reference](http://rubydoc.info/gems/cocaine/)

## Usage

The basic, normal stuff:

```ruby
line = Cocaine::CommandLine.new("echo", "hello 'world'")
line.command # => "echo hello 'world'" 
line.run # => "hello world\n" 
```

Interpolated arguments:

```ruby
line = Cocaine::CommandLine.new("convert", ":in -scale :resolution :out")
line.command(:in => "omg.jpg",
             :resolution => "32x32",
             :out => "omg_thumb.jpg")
# => "convert 'omg.jpg' -scale '32x32' 'omg_thumb.jpg'"
```

It prevents attempts at being bad:

```ruby
line = Cocaine::CommandLine.new("cat", ":file")
line.command(:file => "haha`rm -rf /`.txt") # => "cat 'haha`rm -rf /`.txt'"

line = Cocaine::CommandLine.new("cat", ":file")
line.command(:file => "ohyeah?'`rm -rf /`.ha!") # => "cat 'ohyeah?'\\''`rm -rf /`.ha!'"
```

You can ignore the result:

```ruby
line = Cocaine::CommandLine.new("noisy", "--extra-verbose", :swallow_stderr => true)
line.command # => "noisy --extra-verbose 2>/dev/null"

# ... and on Windows...
line.command # => "noisy --extra-verbose 2>NUL"
```

If your command errors, you get an exception:

```ruby
line = Cocaine::CommandLine.new("git", "commit")
begin
  line.run
rescue Cocaine::ExitStatusError => e
  e.message # => "Command 'git commit' returned 1. Expected 0"
end
```

If your command might return something non-zero, and you expect that, it's cool:

```ruby
line = Cocaine::CommandLine.new("/usr/bin/false", "", :expected_outcodes => [0, 1])
begin
  line.run
rescue Cocaine::ExitStatusError => e
  # => You never get here!
end
```

You don't have the command? You get an exception:

```ruby
line = Cocaine::CommandLine.new("lolwut")
begin
  line.run
rescue Cocaine::CommandNotFoundError => e
  e # => the command isn't in the $PATH for this process.
end
```

But don't fear, you can specify where to look for the command:

```ruby
Cocaine::CommandLine.path = "/opt/bin"
line = Cocaine::CommandLine.new("lolwut")
line.command # => "lolwut", but it looks in /opt/bin for it.
```

You can even give it a bunch of places to look:

```ruby
    FileUtils.rm("/opt/bin/lolwut")
    File.open('/usr/local/bin/lolwut') {|f| f.write('echo Hello') }
    Cocaine::CommandLine.path = ["/opt/bin", "/usr/local/bin"]
    line = Cocaine::CommandLine.new("lolwut")
    line.run # => prints 'Hello', because it searches the path
```

Or just put it in the command:

```ruby
line = Cocaine::CommandLine.new("/opt/bin/lolwut")
line.command # => "/opt/bin/lolwut"
```

You can see what's getting run. The 'Command' part it logs is in green for visibility!

```ruby
line = Cocaine::CommandLine.new("echo", ":var", :logger => Logger.new(STDOUT))
line.run(:var => "LOL!") # => Logs this with #info -> Command :: echo 'LOL!'
```

Or log every command:

```ruby
Cocaine::CommandLine.logger = Logger.new(STDOUT)
Cocaine::CommandLine.new("date").run # => Logs this -> Command :: date
```

## POSIX Spawn

You can potentially increase performance by installing [the posix-spawn
gem](https://rubygems.org/gems/posix-spawn). This gem can keep your
application's heap from being copied when forking command line
processes. For applications with large heaps the gain can be
significant. To include `posix-spawn`, simply add it to your `Gemfile` or,
if you don't use bundler, install the gem.

## Runners

Cocaine will attempt to choose from among 3 different ways of running commands.
The simplest is using backticks, and is the default in 1.8. In Ruby 1.9, it
will attempt to use `Process.spawn`. And, as mentioned above, if the
`posix-spawn` gem is installed, it will attempt to use that. If for some reason
one of the `.spawn` runners don't work for you, you can override them manually
by setting a new runner, like so:

```ruby
Cocaine::CommandLine.runner = Cocaine::CommandLine::BackticksRunner.new
```

And if you really want to, you can define your own Runner, though I can't
imagine why you would.

### JRuby Caveat

If you get `Error::ECHILD` errors and are using JRuby, there is a very good
chance that the error is actually in JRuby. This was brought to our attention
in https://github.com/thoughtbot/cocaine/issues/24 and probably fixed in
http://jira.codehaus.org/browse/JRUBY-6162. You *will* want to use the
`BackticksRunner` if you are unable to update JRuby.

## REE

So, here's the thing about REE: The specs that involve timeouts don't work
there. Not because the logic is unsound, but because the command runs really
slowly. The test passes -- eventually. This was verified using an external
debugger: the process that REE kicks off in the tests reads and writes
surprisingly slowly. For this reason, we cannot recommend using Cocaine with
REE anymore.

It's not something we like, so if anyone has any insight into this problem,
we'd love to hear about it. But, for the time being, we'll consider it more
appropriate to just not use it anymore. Upgrade to 1.9.3, people.

## Feedback

*Security* concerns must be privately emailed to
[security@thoughtbot.com](security@thoughtbot.com).

Question? Idea? Problem? Bug? Comment? Concern? Like using question marks?

[GitHub Issues For All!](https://github.com/thoughtbot/cocaine/issues)

## License

Copyright 2011-2013 Jon Yurek and thoughtbot, inc. This is free software, and
may be redistributed under the terms specified in the
[LICENSE](https://github.com/thoughtbot/cocaine/blob/master/LICENSE)
file.
