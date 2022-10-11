# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
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
    make_loggable(keyscan).tap do |loggable|
      throttler.call(keyscan, delay: config[:repeat_delay]) do
        log('keyscan %<value>s' % loggable, severity: :debug)

        adapter.call(keyscan)
      end.tap do |v|
        log('discard %<value>s' % loggable, severity: :debug) if v.nil?
      end
    end
  end

  protected

  # @return [IrProxy::Throttler]
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

  def make_loggable(keyscan)
    keyscan.to_h.yield_self do |h|
      {
        trans: adapter.trans(keyscan.name),
        value: {
          protocol: h[:protocol],
          scancode: h[:scancode],
          name: h[:name],
        },
      }
    end
  end
end
