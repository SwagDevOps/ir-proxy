# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# Describe an ap;liable option related to config.
#
# @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
class IrProxy::Cli::Command::Behavior::Appliable
  # @param [Hash{Symbol => Object}] definition
  def initialize(definition)
    @struct = Struct.new(*definition.keys).new(*definition.values).freeze

    self.tap { init_methods }.freeze
  end

  def to_h
    struct.to_h
  end

  protected

  attr_reader :struct

  def init_methods
    struct.to_h.each do |key, value|
      self.singleton_class.__send__(:define_method, key) { value }
    end
    struct.to_h.keys # .tap { yield(self) if block }
  end
end
