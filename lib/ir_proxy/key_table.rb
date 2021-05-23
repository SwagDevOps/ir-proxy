# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Keymaps files reader
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
    ((protocol ||= self.protocol)&.to_sym || lambda do
      raise ArgumentError, 'protocol must be set'
    end.call).yield_self do
      raise AbortError if self.protocol and protocol != self.protocol

      self[protocol][value].tap do |v|
        return v.gsub(/^KEY_/, '').upcase.freeze unless v.nil?
      end
    end
  end

  # Retrieve keymap for given protocol.
  #
  # @param [String] protocol
  #
  # @return [Hash{String => String}]
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

  def path
    [Pathname.new(__FILE__).basename('.*'), 'keymaps'].yield_self do |path|
      Pathname.new(__dir__).join(*path)
    end
  end
end
