# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
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
    self.tap { @time = (time || self.class.now.to_f).freeze }.freeze
  end

  # @return Float
  def to_f
    time.dup
  end

  class << self
    alias call new

    def now
      self.new(time: self.time)
    end

    protected

    # @return [Float]
    def time
      Process.clock_gettime(Process::CLOCK_MONOTONIC_RAW).to_f
    end
  end

  # @return [Float]
  def elapsed
    (self.class.new.to_f - self.to_f) * 1.0
  end

  # @param [Float] delay
  #
  # @return [Boolean]
  def elapsed?(delay)
    elapsed > (delay * 1.0)
  end

  alias inspect to_f

  protected

  # @return [Float]
  attr_reader :time
end
