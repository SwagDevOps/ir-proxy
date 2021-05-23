# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Simple wrapper built on top of monotonic clock.
class IrProxy::Clock
  # @param [Float] time
  def initialize(time: nil)
    self.tap { @time = (time || self.class.now).freeze }.freeze
  end

  # @return Float
  def to_f
    time.dup
  end

  class << self
    # @return Float
    def now
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    alias call new
  end

  # @return Float
  def elapsed
    self.class.new.to_f - self.to_f
  end

  # @param [Float] delay
  #
  # @return Boolean
  def elapsed?(delay)
    elapsed > delay
  end

  alias inspect to_f

  protected

  # @return Float
  attr_reader :time
end
