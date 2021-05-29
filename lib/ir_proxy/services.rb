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
  throttler: lambda do
    {
      IrProxy::KeyScan => lambda do |current, previous|
        # @type [IrProxy::KeyScan] current
        # @type [IrProxy::KeyScan] previous
        ([[:protocol, :scancode, :toggle]] * 2).map.with_index do |keys, index|
          keys.map { |key| [current, previous].fetch(index).to_h.fetch(key) }
        end.yield_self do |values|
          values.fetch(0) != values.fetch(1)
        end
      end
    }.yield_self do |rules|
      IrProxy::Throttler.new(rules)
    end
  end,
  'hl.yaml': lambda do
    lambda do |source, output: $stdout|
      # autoload(:Rouge, 'rouge')
      require 'rouge'

      return source unless output.isatty

      Rouge::Formatters::Terminal256.new.format(Rouge::Lexers::YAML.new.lex(source))
    end
  end,
  # events listeners ------------------------------------------------
  'events:line.incoming': -> { IrProxy::Events::LineIncoming.new },
  'events:key_scan': -> { IrProxy::Events::KeyScan.new },
  # adapters --------------------------------------------------------
  adapter: -> { IrProxy::Adapter.instance },
  'adapters:dummy': -> { IrProxy::Adapter::Dummy.new },
  'adapters:xdotool': -> { IrProxy::Adapter::Xdotool.new },
}
