# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Intercept and process key down events
class IrProxy::Events::KeyScan < IrProxy::Events::Listener
  autoload(:Shellwords, 'shellwords')
  include(IrProxy::Events::HasLogger)

  def initialize(**kwargs)
    super.tap do
      @logger = kwargs[:logger]
      @adapter = kwargs[:adapter] || IrProxy[:adapter]
      @config = kwargs[:config] || IrProxy[:config]
      @throttler = kwargs[:throttler] || IrProxy[:throttler]
    end.freeze
  end

  # @param [IrProx::KeyScan] keyscan
  def call(keyscan)
    [keyscan.name.to_s, adapter.trans(keyscan.name)].tap do |k, v|
      self.log("key down #{k.inspect} -> #{v.inspect}", severity: :info)
    end
    # process event ---------------------------------------------------
    adapter.call(keyscan)
  end

  protected

  # @return [IrProxy::Thottler]
  attr_reader :throttler

  # @return [IrProxy::Config]
  attr_reader :config

  # @return [IrProxy::Adapter::Adapter]
  attr_reader :adapter

  # @return [IrProxy::Logger, nil]
  def logger
    (@config || IrProxy[:config])[:logger].tap do |b|
      return b ? super : nil
    end
  end
end
