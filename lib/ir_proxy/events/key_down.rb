# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Intercept and process key down events
class IrProxy::Events::KeyDown < IrProxy::Events::Listener
  autoload(:Shellwords, 'shellwords')

  # @param [IrProx::KeyScan] keyscan
  def call(keyscan)
    [keyscan.name.to_s, adapter.trans(keyscan.name)].tap do |k, v|
      log("key down #{k.inspect} -> #{v.inspect}", severity: :info)
    end

    adapter.call(keyscan).tap do |command|
      unless adapter.dummy?
        (command ? Shellwords.join(command) : command).tap do |s|
          log("command: #{s.inspect}", severity: :debug)
        end
      end
    end
  end

  def initialize(**kwargs)
    @adapter = kwargs[:adapter]
    @logger = kwargs[:logger]
    (kwargs[:process_manager] || IrProxy[:process_manager]).tap do |pm|
      @process_manager = pm
    end
  end

  protected

  # @return [IrProxy::ProcessManager]
  attr_reader :process_manager

  # @return [IrProxy::Adapter::Adapter]
  def adapter
    @adapter ||= IrProxy[:adapter]
  end

  # @return [IrProxy::Logger]
  def logger
    @logger ||= IrProxy[:logger]
  end

  def log(message, **kwargs)
    return self unless logger

    Thread.new { logger.public_send(kwargs[:severity] || :debug, message) }
  end
end
