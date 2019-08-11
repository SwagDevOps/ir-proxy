# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Container for services (service locator).
class IrProxy::Container
  autoload(:Singleton, 'singleton')
  include Singleton
  class << self
    # @!attribute instance
    #   @return [IrProxy::ProcessManager]
  end

  # @return [Object]
  def get(id)
    dependencies.fetch(id.to_sym)
  end

  # @return [Boolean]
  def has(id)
    key?(id.to_sym)
  end

  # @return [self]
  def set(id, instance)
    self.tap do
      (instance.is_a?(Proc) ? instance.call : instance).tap do |value|
        dependencies.merge!(id.to_sym => value)
      end
    end
  end

  # @return [Boolean]
  def empty?
    dependencies.empty?
  end

  # @return [Array<Symbol>]
  def keys
    dependencies.keys
  end

  def freeze
    super.tap { dependencies.freeze }
  end

  protected

  # @return [Hash{Symbol => Object}]
  attr_accessor :dependencies

  def initialize
    @dependencies = {}
  end
end
