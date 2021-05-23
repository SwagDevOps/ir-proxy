# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Keymaps files reader
#
# An optional protocol can be set on `initialize`.
# It will restrict `#call` to given protocol, raising `AbortError` if optional protocol differs.
class IrProxy::KeyTable
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  {
    AbortError: 'abort_error',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("key_table/#{fp}")) }

  # @param [String, Symbol, nil] protocol
  def initialize(protocol: nil)
    self.tap { @protocol = protocol&.to_sym }.freeze
  end

  # Retrieve bame for given value with optional protocol (when already set).
  #
  # When protocol is set, optional protocol is ignored.
  #
  # @param [Integer] value
  # @param [String, Symbol, nil] protocol
  #
  # @return String, nil
  def call(value, protocol: nil)
    self[ensure_protocol!(protocol)].yield_self do |keymap|
      keymap[value]&.yield_self { |v| v.gsub(/^KEY_/, '').upcase.freeze }
    end
  end

  # Denote given protocol has a keymaps file.
  #
  # @return [Boolean]
  def has?(protocol)
    !self[protocol].nil?
  end

  # Retrieve keymap for given protocol.
  #
  # @param [String] protocol
  #
  # @return Hash{String => String}
  def [](protocol)
    read_file(protocol)
  end

  protected

  attr_reader :protocol

  def read_file(protocol)
    path.join("#{protocol}.yml").yield_self do |file|
      return {} unless file.file? and file.readable?

      return YAML.safe_load(file.read)
    end
  end

  # Get path to keympas directory.
  #
  # @return Pathname
  def path
    [Pathname.new(__FILE__).basename('.*'), 'keymaps'].yield_self do |path|
      Pathname.new(__dir__).join(*path)
    end
  end

  # @param [String, Symbol, nil] protocol
  #
  # @return Symbol
  def ensure_protocol!(protocol)
    (self.protocol || protocol).tap do
      raise ArgumentError, 'protocol must be set' if self.protocol.nil? and protocol.nil?

      raise AbortError if self.protocol and !protocol.nil? and protocol.to_sym != self.protocol
    end.to_sym
  end
end
