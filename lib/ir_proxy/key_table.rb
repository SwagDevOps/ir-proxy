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
#
# Keymaps files are retrieved from `config_path` directory and from lib directory.
class IrProxy::KeyTable
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  {
    AbortError: 'abort_error',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("key_table/#{fp}")) }

  def initialize(**kwargs)
    self.tap do
      (kwargs[:config] || IrProxy['config']).to_path.tap do |config_path|
        @config_path = Pathname.new(config_path).freeze
      end
    end.freeze
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

  # @return [String, Symbol] for enforced protocol
  attr_reader :protocol

  # @ertrun [Pathname]
  attr_reader :config_path

  # Read file for given protocol.
  #
  # File can be loctaed in user config directory (prior) or in lib directory.
  # Paths are tested sequentially.
  #
  # @return [Hash, Hash{Integer => String}]
  def read_file(protocol)
    {}.tap do
      paths.each do |path|
        path.join("#{protocol}.yml").yield_self do |file|
          return YAML.safe_load(file.read) if file.file? and file.readable?
        end
      end
    end
  end

  # Get paths to keympas directories.
  #
  # @return Pathname
  def paths
    [
      config_path,
      Pathname.new(__dir__).join(Pathname.new(__FILE__).basename('.*')),
    ].map { |path| Pathname.new(path).join('keymaps') }
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
