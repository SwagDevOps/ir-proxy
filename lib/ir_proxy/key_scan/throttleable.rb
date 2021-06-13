# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../key_scan'

# Throttleable related methods.
module IrProxy::KeyScan::Throttleable
  # Denote given `other` is throttleable against current instance.
  #
  # @param [IrProxy::KeyScan] other
  #
  # @return [Boolean]
  def throttleable?(other)
    return false unless other.is_a?(self.class)

    [self, other].map { |v| v.__send__(:throttleable) }.uniq.yield_self do |compared|
      1 == compared.size
    end
  end

  protected

  # @api private
  #
  # @return [Array<Symbol>]
  def throttleable_keys
    self.class.const_get(:THROTTLEABLE_KEYS)
  end

  # Get a subset of the `Hash` representation.
  #
  # @see #throttleable?
  #
  # @return [Hash{Symbol => Object}]
  def throttleable
    self.to_h.yield_self do |h|
      throttleable_keys
        .map { |k| [k, h.fetch(k, nil)] }
        .to_h
        .transform_values(&:freeze)
        .freeze
    end
  end
end
