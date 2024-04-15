# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

{
  'adapter.factory': IrProxy::Adapter,
  clock: IrProxy::Clock,
  inflector: lambda do
    require 'dry/inflector'

    Dry::Inflector.new
  end.call.freeze,
  progname: File.dirname(__FILE__).yield_self { |dir| File.basename(dir).gsub('_', '-') },
}.yield_self do |vars|
  {
    process_manager: -> { IrProxy::ProcessManager.new },
    events_dispatcher: -> { IrProxy::Events::Dispatcher.new },
    key_scanner: -> { IrProxy::KeyScan },
    config: -> { IrProxy::Config.new(nil, optional: true) },
    lock: -> { IrProxy::FileLock.new },
    cli: -> { IrProxy::Cli.new },
    sampler: -> { IrProxy::Sampler.new },
    logger: -> { IrProxy::Logger.new('/dev/stdout', progname: IrProxy[:progname]) },
    keytable: -> { IrProxy::KeyTable.new },
    protocol: -> { IrProxy.container[:config].to_h.fetch(:protocol, nil) }, # Get value from config
    throttler: lambda do
      {
        IrProxy::KeyScan => lambda do |current, previous|
          # @type [IrProxy::KeyScan] current
          # @type [IrProxy::KeyScan] previous
          !current.throttleable?(previous)
        end
      }.yield_self { |rules| IrProxy::Throttler.new(rules) }
    end,
    yaml_highlighter: -> { IrProxy::SyntaxHighlighter.new(:YAML) },
    # events listeners ------------------------------------------------
    'events:line.incoming': -> { IrProxy::Events::LineIncoming.new },
    'events:key_scan': -> { IrProxy::Events::KeyScan.new },
    # adapters --------------------------------------------------------
    adapter: -> { vars.fetch(:'adapter.factory').instance },
    'adapters:dummy': -> { IrProxy::Adapter::Dummy.new },
    'adapters:xdotool': -> { IrProxy::Adapter::Xdotool.new },
  }.yield_self { |services| vars.merge(services) }
end
