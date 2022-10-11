# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Intercept and process lines
class IrProxy::Events::LineIncoming < IrProxy::Events::Listener
  def initialize(**kwargs)
    super
    @key_scanner = kwargs[:key_scanner] || IrProxy[:key_scanner]
  end

  # @param [String] line
  #
  # @see IrProxy::Events::KeyDown#call
  # @see IrProxy::KeyScan.call
  #
  # @return Hash keyscan
  def call(line)
    scan(line).tap do |event|
      events_dispatcher.dispatch(:key_scan, event) unless event.empty?
    end
  end

  protected

  # @return [Class]
  attr_reader :key_scanner

  # @return [IrProxy::KeyScan]
  def scan(line)
    key_scanner.call(line)
  end
end
