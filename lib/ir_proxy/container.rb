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

  def inspect
    self.keys.inspect
  end

  # @return [Object]
  def get(id)
    unless dependencies.key?(id.to_sym)
      constructors.fetch(id.to_sym).call.tap do |instance|
        dependencies[id.to_sym] = instance
        constructors.delete(id.to_sym)
      end
    end

    dependencies.fetch(id.to_sym)
  end

  # @return [Boolean]
  def has(id)
    key?(id.to_sym) || constructors.key?(id.to_sym)
  end

  # @return [self]
  def set(id, instance)
    self.tap do
      # @formatter:off
      (instance.is_a?(Proc) ? constructors : dependencies)
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
    dependencies.keys.push(*constructors.keys).sort
  end

  def freeze
    super.tap do
      keys.each { |key| self.get(key) }
      constructors.freeze unless constructors.frozen?
      dependencies.freeze unless dependencies.frozen?
    end
  end

  def to_h
    self.keys.map { |k| [k, self.get(k)] }.to_h
  end

  protected

  # @return [Hash{Symbol => Object}]
  attr_accessor :dependencies

  # Stored dependencies
  #
  # @return [Hash{Symbol => Object}]
  attr_accessor :constructors

  def initialize
    @dependencies = Concurrent::Hash.new
    @constructors = Concurrent::Hash.new
  end
end
