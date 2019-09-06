# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Intercept and process key down events
class IrProxy::Events::KeyDown < IrProxy::Events::Listener
  # @param [IrProx::KeyScan] keyscan
  def call(keyscan)
    log_keyscan(keyscan)
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

  # @param [IrProx::KeyScan] keyscan
  #
  # @return [self]
  def log_keyscan(keyscan)
    self.tap do
      return self unless logger

      Thread.new do
        [keyscan.name.to_s, adapter.trans(keyscan.name)].tap do |k, v|
          "key down #{k.inspect} -> #{v.inspect}".tap { |s| logger.debug(s) }
        end
      end
    end
  end
end
