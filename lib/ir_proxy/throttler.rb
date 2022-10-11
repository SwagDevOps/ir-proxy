# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Throttler.
#
# Sample of use:
#
# ```ruby
# class Sample
#   def initialize(value)
#     @value = value
#     @clock = IrProxy::Clock.new
#   end
#
#   def elapsed?(delay)
#     @clock.elapsed?(delay)
#   end
#
#   def to_i
#     @value.to_i
#   end
# end
#
# {
#   Sample => lambda do |current, previous|
#     current.to_i != previous.to_i
#   end
# }.yield_self { |rules| IrProxy::Throttler.new(rules) }.yield_self do |throttler|
#   (1..42).map do |v|
#     sample = Sample.new(v).tap { sleep(0.01) }
#     throttler.call(sample, delay: 0.1) { |v| pp(v) }
#   end
# end
# ```
class IrProxy::Throttler
  def initialize(throttables = {})
    @throttables = throttables.freeze
    @history = {}
  end

  # @param [Object] throttable
  # @param [Float] delay
  #
  # @return [Object, nil]
  def call(throttable, delay:)
    return nil unless check(throttable, delay: delay)

    history[throttable.class] = throttable
    block_given? ? yield(throttable) : throttable
  end

  protected

  # @return [Hash{Class => Proc}]
  attr_reader :throttables

  # @return [Hash{Class => Object}]
  attr_reader :history

  # rubocop:disable Metrics/AbcSize

  # @param [Object] throttable
  # @param [Float] delay
  def check(throttable, delay:)
    false.tap do
      return false unless throttables.key?(throttable.class)

      return true unless history.key?(throttable.class)

      return true if throttables.fetch(throttable.class)&.call(throttable, history.fetch(throttable.class))

      return true if history.key?(throttable.class) and history.fetch(throttable.class).elapsed?(delay)
    end
  end

  # rubocop:enable Metrics/AbcSize
end
