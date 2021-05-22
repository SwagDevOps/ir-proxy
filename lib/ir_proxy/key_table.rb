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

  def initialize(protocol: nil)
    self.tap { @protocol = protocol.to_sym if protocol }.freeze
  end

  # Retrieve bame for given value with optional protocol (when already set).
  #
  # When protocol is set, optional protocol is ignored.
  #
  # @param [Integer] value
  # @param [String, Symbol] protocol
  #
  # @return String, nil
  def call(value, protocol: nil)
    self[self.protocol || protocol][value].tap do |v|
      return v.gsub(/^KEY_/, '').upcase.freeze unless v.nil?
    end
  end

  # Retrieve keymap for given protocol.
  #
  # @param [String] protocol
  #
  # @return [Hash{String => String}]
  def [](protocol)
    return nil if protocol.nil?

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
