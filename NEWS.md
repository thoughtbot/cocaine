New for 0.4.2:

* Loggers that don't understand `tty?`, like `ActiveSupport::BufferedLogger`
  will still work.

New for 0.4.1:

* Introduce FakeRunner for testing, so you don't really run commands.
* Fix logging: output the actual command, not the un-interpolated pattern.
* Prevent color codes from being output if log destination isn't a TTY.

New for 0.4.0:

* Moved interpolation to the `run` method, instead of interpolating on `new`.
* Remove official support for REE.

New for 0.3.2:

* Fix a hang when processes wait for IO.

New for 0.3.1:

* Made the `Runner` manually swappable, in case `ProcessRunner` doesn't work
  for some reason.
* Fixed copyright years.

New for 0.3.0:

* Support blank arguments.
* Add `CommandLine#unix?`.
* Add `CommandLine#exit_status`.
* Automatically use `POSIX::Spawn` if available.
* Add `CommandLine#environment` as a hash of extra `ENV` data..
* Add `CommandLine#runner` which produces an object that responds to `#call`.
* Fix a race condition but only on Ruby 1.9.
