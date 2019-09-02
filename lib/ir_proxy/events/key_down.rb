# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Intercept and process lines
class IrProxy::Events::KeyDown < IrProxy::Events::Listener
  # @param [IrProx::KeyScan] keyscan
  def call(keyscan)
    pp(keyscan)
  end

  def initialize(**kwargs)
    @adapter = kwargs[:adapter]
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
end
