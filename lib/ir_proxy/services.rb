# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

{
  progname: File.dirname(__FILE__).yield_self { |dir| File.basename(dir).gsub('_', '-') },
  process_manager: -> { IrProxy::ProcessManager.new },
  events_dispatcher: -> { IrProxy::Events::Dispatcher.new },
  key_scanner: -> { IrProxy::KeyScan },
  clock: IrProxy::Clock,
  config: -> { IrProxy::Config.new(nil, optional: true) },
  lock: -> { IrProxy::FileLock.new },
  cli: -> { IrProxy::Cli.new },
  sampler: -> { IrProxy::Sampler.new },
  logger: -> { IrProxy::Logger.new('/dev/stdout', progname: IrProxy[:progname]) },
  keytable: -> { IrProxy::KeyTable.new },
  # events listeners ------------------------------------------------
  'events:line.incoming': -> { IrProxy::Events::LineIncoming.new },
  'events:key_scan': -> { IrProxy::Events::KeyScan.new },
  # adapters --------------------------------------------------------
  adapter: -> { IrProxy::Adapter.instance },
  'adapters:dummy': -> { IrProxy::Adapter::Dummy.new },
  'adapters:xdotool': -> { IrProxy::Adapter::Xdotool.new },
}
