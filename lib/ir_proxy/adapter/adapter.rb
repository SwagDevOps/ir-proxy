# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Base adapter to perform keyboard input.
#
# @abstract
class IrProxy::Adapter::Adapter
  include(IrProxy::Adapter::HasLogger)

  # @return [String]
  attr_reader :executable

  # @return [String]
  attr_reader :name

  def initialize(**kwargs)
    @executable = kwargs[:executbale] || self.class.executable
    @config = kwargs[:config] || IrProxy[:config]
    @logger = kwargs[:logger] || IrProxy[:logger]
    @name = self.class.identifier
    @process_manager = kwargs[:process_manager] || IrProxy[:process_manager]
  end

  def dummy?
    name == :dummy
  end

  # Get adapter config.
  #
  # @return [Hash]
  def adapter_config
    config[:adapter] || {}
  end

  # Get keymap from config
  #
  # @return [Hash]
  def keymap
    (config[:keymap] || {})
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

  # @return [IrProxy::ProcessManager]
  attr_reader :process_manager

  # @return [IrPoxy::Config]
  attr_reader :config

  class << self
    attr_accessor :executable
  end

  # @return [IrProxy::Logger, nil]
  def logger
    (@config || IrProxy[:config])[:logger].tap do |b|
      return b ? super : nil
    end
  end
end
