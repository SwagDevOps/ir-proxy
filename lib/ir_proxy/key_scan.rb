# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Provide file locking (based on `flock`).
class IrProxy::KeyScan
  # 1565163195.634614: event type EV_KEY(0x01) key_down: KEY_NUMERIC_2(0x0202)
  REGEXP = /(?<time>[0-9]+\.[0-9]+):\s+
event\s+type\s+EV_KEY
\((?<code_1>[0-9]+x[0-9 a-f A-F]+)\)\s+
key_(?<type>down|up):\s+
KEY_(?<name>[A-Z]+[A-Z_0-9]*)
\((?<code_2>[0-9]+x[0-9 a-f A-F]+)\)/x.freeze

  # @param [String] line
  def initialize(line)
    @line = line.to_str
  end

  # @return [Hash{String => String}]
  def parsed
    @parsed ||= lambda do
      self.class.parse(line).to_h
    end.call.freeze
  end

  def to_s
    line
  end

  def empty?
    to_h.empty?
  end

  # @return [Symbol|nil] lowercase
  def type
    to_h[:type]
  end

  # @return [Boolean]
  def down?
    type == :down
  end

  # @return [Boolean]
  def up?
    type == :up
  end

  # @return [Symbol] uppercase
  def name
    to_h[:name]
  end

  alias to_str to_s

  alias to_h parsed

  class << self
    # @param [String] line
    #
    # @return [KeyScan]
    def call(line)
      self.new(line)
    end

    # @param [String] line
    #
    # @return [Hash{String => String}|nil]
    def parse(line)
      REGEXP.match(line).tap do |m|
        return nil unless m

        # @formatter:off
        Hash[m.named_captures.sort]
          .map { |k, v| [k.to_sym, v] }.to_h.tap do |scan|
          scan[:time] = scan.fetch(:time).to_f
          scan[:name] = scan.fetch(:name).upcase.to_sym
          scan[:type] = scan.fetch(:type).downcase.to_sym

          return scan
        end
        # @formatter:on
      end
    end
  end

  protected

  # @return [String]
  attr_reader :line
end
