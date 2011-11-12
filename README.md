# Cocaine

A small library for doing (command) lines.

## Feedback

Question? Idea? Problem? Bug? Something else? Comment? Concern? Like use question marks?

[GitHub Issues For All!](https://github.com/thoughtbot/cocaine/issues)

## Usage

The basic, normal stuff.

```ruby
line = Cocaine::CommandLine.new("command", "some 'crazy' options")
line.command      # => "command some 'crazy' options"
output = line.run # => Get you some output!
```

Allowing arguments to be dynamic:

```ruby
line = Cocaine::CommandLine.new("convert", ":in -scale :resolution :out",
                                :in => "omg.jpg",
                                :resolution => "32x32",
                                :out => "omg_thumb.jpg")
line.command # => "convert 'omg.jpg' -scale '32x32' 'omg_thumb.jpg'"
```

It prevents attempts at being bad:

```ruby
line = Cocaine::CommandLine.new("cat", ":file", :file => "haha`rm -rf /`.txt")
line.command # => "cat 'haha`rm -rf /`.txt'"

line = Cocaine::CommandLine.new("cat", ":file", :file => "ohyeah?'`rm -rf /`.ha!")
line.command # => "cat 'ohyeah?'\\''`rm -rf /`.ha!'"
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
    `echo 'echo Hello' > /usr/local/bin/lolwut`
    Cocaine::CommandLine.path = ["/opt/bin", "/usr/local/bin"]
    line = Cocaine::CommandLine.new("lolwut")
    line.run # => prints 'Hello', because it searches the path
```

Or just put it in the command:

```ruby
line = Cocaine::CommandLine.new("/opt/bin/lolwut")
line.command # => "/opt/bin/lolwut"
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

You can see what's getting run. The 'Command' part it logs is in green for visibility!

```ruby
line = Cocaine::CommandLine.new("echo", ":var", :var => "LOL!", :logger => Logger.new(STDOUT))
line.run # => Logs this with #info -> Command :: echo 'LOL!'
```

But you don't have to, as you saw above where it doesn't use this. But you CAN log every command!

```ruby
Cocaine::CommandLine.logger = Logger.new(STDOUT)
Cocaine::CommandLine.new("date").run # => Logs this -> Command :: date
```

## License

Copyright 2011 Jon Yurek and thoughtbot, inc. This is free software, and may be redistributed under the terms specified in the LICENSE file.
