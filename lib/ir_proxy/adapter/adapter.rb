# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Base adapter to perform keyboard input.
#
# Config is based on the adapter identifier (name).
# As a result, adapdter does not store a gliobal config object,
# but the necessary subset extracted from the global config.
#
# @abstract
class IrProxy::Adapter::Adapter
  include(IrProxy::Adapter::HasLogger)

  # @return [String]
  attr_reader :name

  def initialize(**kwargs)
    self.tap do
      @name = self.class.identifier
      @config = kwargs[:config] || IrProxy[:config].to_h.fetch(:adapters, {}).fetch(self.name.to_s, {})
      @logger = kwargs[:logger] || IrProxy[:logger]
    end.freeze
  end

  def dummy?
    name == :dummy
  end

  # @return [String]
  def executbale
    config.fetch('executable', self.class.executable)
  end

  # Get keymap from config
  #
  # @return [Hash]
  def keymap
    config.fetch('keymap', {}).freeze
  end

  # Get mapping for given key name.
  #
  # @return [String|nil]
  def trans(key_name)
    keymap.fetch(key_name.to_s, nil).tap do |v|
      return v.nil? ? nil : v.to_s
    end
  end

  # Execute action for given keyscan
  #
  # @param [IrProxy::KeyScan] keyscan
  def call(keyscan)
    keyscan.name.tap do |key_name|
      command_for(key_name).tap do |command|
        process_manager.sh(*command) if command

        return command
      end
    end
  end

  class << self
    # Get adapter identifier.
    #
    # @return [String]
    def identifier
      Dry::Inflector.new.yield_self do |inf|
        self.name.split('::')[-1].tap do |name|
          return inf.underscore(name).to_sym
        end
      end
    end
  end

  # Get a command line for given key name.
  #
  # @todo actual implementation
  #
  # @return [Array<String>, nil]
  def command_for(key_name)
    trans(key_name).yield_self do |input|
      return nil if input.nil?

      return [input.to_s]
    end
  end

  protected

  # @return [IrPoxy::Config]
  attr_reader :config

  def logger
    super if !!config.fetch('logger', true)
  end

  class << self
    # @return [String ]
    attr_reader :executable

    protected

    attr_writer :executable
  end
end
