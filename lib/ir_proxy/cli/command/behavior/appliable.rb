# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# Describe an appliable option related to config.
#
# @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
class IrProxy::Cli::Command::Behavior::Appliable
  # @param [Hash{Symbol => Object}] definition
  def initialize(definition, name:)
    @name = name.to_sym
    self.refine(definition).tap do |h|
      @struct = Struct.new(*h.keys).new(*h.values).freeze
    end

    self.tap { init_methods }.freeze
  end

  def to_h
    struct.to_h
  end

  protected

  # @return [Struct]
  attr_reader :struct

  # @return [Symbol]
  attr_reader :name

  def init_methods
    struct.to_h.each do |key, value|
      self.singleton_class.__send__(:define_method, key) { value }
    end
    struct.to_h.keys
  end

  def refine(definition)
    definition.tap do
      if ::IrProxy::Config.defaults.key?(name)
        # if default is set from the command line, it will override config.
        definition.delete(:default)
      end
    end
  end
end
