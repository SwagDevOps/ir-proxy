# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../key_scan'

# Describe a protocol.
#
# Protocol has an original value and an (optional) forced value.
# When size is greater than 1, first value is the forced one.
class IrProxy::KeyScan::Protocol
  def initialize(original, forced = nil)
    @values = [forced, original].compact.uniq.map(&:to_sym).freeze
  end

  def forced?
    self.to_a.size > 1
  end

  def original
    self.forced? ? self.to_a.fetch(1) : self.to_sym
  end

  def to_sym
    self.to_a.fetch(0)
  end

  def to_s
    self.to_sym.to_s.freeze
  end

  # @return [Array<Symbol>]
  def to_a
    self.values.dup
  end

  def inspect
    self.forced? ? self.to_a : self.to_sym
  end

  protected

  # @return [Array<Symbol>]
  attr_reader :values
end
