# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# List appliable options related to config.
#
# @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
class IrProxy::Cli::Command::Behavior::Appliables
  # @param [Hash{Symbol => Hash}] appliables
  def initialize(appliables)
    @items = appliables.map { |key, value| [key, make(value, name: key)] }.to_h.freeze
  end

  # @return [Hash{Symbol => Hash}]
  def to_h
    items.dup
  end

  def each(*args, &block)
    to_h.each(*args, &block)
  end

  def keys
    to_h.keys
  end

  def inspect
    to_h
  end

  protected

  attr_reader :items

  # @param [Hash{Symbol => Hash}] value
  # @param [Symbol] name
  #
  # @return [IrProxy::Cli::Command::Behavior::Appliable]
  def make(value, name:)
    IrProxy::Cli::Command::Behavior::Appliable.new(value, name: name)
  end
end
