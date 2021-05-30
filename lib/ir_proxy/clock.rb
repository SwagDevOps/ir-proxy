# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Simple wrapper built on top of monotonic clock.
#
# @see https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/
# @see https://webdevdesigner.com/q/what-is-the-difference-between-clock-monotonic-clock-monotonic-raw-120918/
class IrProxy::Clock
  # @param [Float] time
  def initialize(time: nil)
    self.tap { @time = decimal(time || self.class.now).freeze }.freeze
  end

  # @return Float
  def to_f
    to_d.to_f
  end

  def to_d
    time.dup
  end

  def to_s
    to_d.to_s
  end

  class << self
    alias call new

    def now
      self.new(time: self.time)
    end

    protected

    # @return [Float]
    def time
      Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f
    end
  end

  # @return [Float]
  def elapsed
    (self.class.new.to_d - self.to_d).to_f
  end

  # @param [Float] delay
  #
  # @return [Boolean]
  def elapsed?(delay)
    decimal(elapsed) > decimal(delay.to_f)
  end

  alias inspect to_f

  protected

  # @return [Float]
  attr_reader :time

  # @api private
  #
  # @param [Float] value
  def decimal(value)
    require 'bigdecimal'

    BigDecimal(value.to_f.to_s)
  end
end
