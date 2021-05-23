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
      @adapter = kwargs[:adapter]
      @logger = kwargs[:logger]
      @config = kwargs[:config]
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

  # @return IrProxy::ProcessManager
  attr_reader :process_manager

  # @return IrProxy::Adapter::Adapter
  def adapter
    # noinspection RubyYardReturnMatch
    @adapter || IrProxy[:adapter]
  end

  # @return IrProxy::Logger, nil]
  def logger
    (@config || IrProxy[:config])[:logger] ? super : nil
  end
end
