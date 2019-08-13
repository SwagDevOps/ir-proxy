# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Container for services (service locator).
class IrProxy::Container
  autoload(:Concurrent, 'concurrent')
  autoload(:Singleton, 'singleton')
  include Singleton
  class << self
    # @!attribute instance
    #   @return [IrProxy::ProcessManager]
  end

  # @return [Object]
  def get(id)
    unless dependencies.key?(id.to_sym)
      callables.fetch(id.to_sym).call.tap do |instance|
        dependencies[id.to_sym] = instance
        callables.delete(id.to_sym)
      end
    end

    dependencies.fetch(id.to_sym)
  end

  # @return [Boolean]
  def has(id)
    key?(id.to_sym) || callables.key?(id.to_sym)
  end

  # @return [self]
  def set(id, instance)
    self.tap do
      # @formatter:off
      (instance.is_a?(Proc) ? callables : dependencies)
        .merge!(id.to_sym => instance)
      # @formatter:on
    end
  end

  # @return [Boolean]
  def empty?
    keys.empty?
  end

  # @return [Array<Symbol>]
  def keys
    dependencies.keys.push(*callables.keys).sort
  end

  def freeze
    super.tap do
      keys.each { |key| self.get(key) }
      callables.freeze
      dependencies.freeze
    end
  end

  protected

  # @return [Hash{Symbol => Object}]
  attr_accessor :dependencies

  # @return [Hash{Symbol => Object}]
  attr_accessor :callables

  def initialize
    @dependencies = Concurrent::Hash.new
    @callables = Concurrent::Hash.new
  end
end
