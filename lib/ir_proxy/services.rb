# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# @formatter:off
{
  'progname': Sys::Proc.progname,
  'process_manager': -> { ProcessManager.new },
  'events_dispatcher': -> { Events::Dispatcher.new },
  'key_scanner': -> { KeyScan },
  'config': -> { IrProxy::Config.new(nil, optional: true) },
  'lock': -> { FileLock.new },
  'cli': -> { Cli.new },
  'sampler': -> { Sampler.new },
  'logger': -> { Logger.new('/dev/stdout', progname: IrProxy[:progname]) },
  # events listeners ------------------------------------------------
  'events:line.incoming': -> { Events::LineIncoming.new },
  'events:key.down': -> { Events::KeyDown.new },
  # adapters --------------------------------------------------------
  'adapter': -> { Adapter.instance },
  'adapters:dummy': -> { Adapter::Dummy.new },
  'adapters:xdotool': -> { Adapter::Xdotool.new },
}
# @formatter:on
