# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Parse lines from `lirc protocol`
#
# @see https://www.sbprojects.net/knowledge/ir/rc6.php
class IrProxy::KeyScan
  # Expression used to capture incoming lines
  #
  # Sample lines:
  #
  # ```
  # 62086.432173: lirc protocol(rc6_mce): scancode = 0x800f7422 toggle=1
  # 62086.432173: lirc protocol(rc6_mce): scancode = 0x800f7422
  # ```
  #
  # @api private
  REGEXP = /^(?<time>[0-9]+\.[0-9]+):\s+
lirc\s+protocol\((?<protocol>.*)\):\s+
scancode\s*=\s*(?<scancode>0[xX][0-9a-fA-F]+)\s*
(?<toggle>toggle=[0-9]+)?
/x.freeze

  # Keys used to compare key scan for equality.
  #
  # @api private
  #
  # @see #throttleable
  # @see #throttleable?
  THROTTLEABLE_KEYS = [:protocol, :scancode].freeze

  {
    Protocol: 'protocol',
    Throttleable: 'throttleable',
  }.each { |s, fp| autoload(s, "#{__dir__}/key_scan/#{fp}") }

  include IrProxy::KeyScan::Throttleable

  # @return [IrProxy::Clock]
  attr_reader :time

  # @return [Hash{Symbol => Object}]
  attr_reader :parsed

  # @param [String] line
  #
  # @option kwargs [IrPoxy::Keytable] :keytable
  # @option kwargs [IrProxy::Clock] :clock
  # @option kwargs [String, Symbol] :protocol
  def initialize(line, **kwargs)
    self.tap do
      @line = line.to_str
      @parsed = self.class.parse(line).to_h.transform_values(&:freeze).freeze
      @keytable = kwargs[:keytable] || IrProxy[:keytable]
      @time = (kwargs[:clock] || IrProxy[:clock]).call.freeze
      @enforced_protocol = (kwargs[:protocol] || IrProxy['protocol'])&.to_sym
    end.freeze
  end

  def to_s
    line
  end

  def empty?
    to_h.empty?
  end

  # @see IrProxy::KeyScan::Protocol
  #
  # @return [Symbol] SHOULD be lowercase
  def protocol
    to_h[:protocol].to_sym
  end

  # @return [String]
  def scancode
    to_h[:scancode]
  end

  # @return [Symbol] uppercase
  def name
    to_h[:name]
  end

  def to_h
    parsed.dup.to_h.merge(parsed_additions).yield_self do |h|
      Hash[h.sort].transform_values(&:freeze).freeze
    end
  end

  def elapsed?(delay)
    time.elapsed?(delay)
  end

  alias to_str to_s

  class << self
    # @param [String] line
    #
    # @return [KeyScan]
    def call(line)
      self.new(line)
    end

    # @param [String] line
    #
    # @return [Hash{Symbol => Object}, nil]
    def parse(line)
      REGEXP.match(line).tap do |m|
        return nil unless m

        return Hash[m.named_captures.sort].transform_keys(&:to_sym).yield_self do |scan|
          prepare(scan).yield_self { |prepared| scan.merge(prepared) }
        end
      end
    end

    protected

    # @param [Hash{Symbol => Object}] scan
    #
    # @return [Hash{Symbol => Object}]
    def prepare(scan)
      {
        time: scan.fetch(:time).to_f,
        protocol: scan.fetch(:protocol).to_sym,
        value: scan.fetch(:scancode).to_i(16), # hexadecimal value to integer as seen in YAML files
        toggle: !!scan.fetch(:toggle),
      }
    end
  end

  protected

  # @return [String]
  attr_reader :line

  # @return [IrProxy::KeyTable]
  attr_reader :keytable

  # @return [Symbol]
  attr_reader :enforced_protocol

  # Get additions for parsed result.
  #
  # @return [Hash{Symbol => Object}]
  def parsed_additions
    return {} if self.parsed.empty?

    IrProxy::KeyScan::Protocol.new(parsed.fetch(:protocol), self.enforced_protocol).yield_self do |protocol|
      {
        clock: time,
        name: keytable.call(parsed[:value]&.to_i, protocol: protocol.to_sym),
        protocol: protocol
      }
    end
  end
end
