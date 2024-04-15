# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'
require 'thor/error'

# Apply configuration
class IrProxy::Cli::Command::Behavior::Configurator
  include IrProxy::Concern::ContainerAware

  {
    AdapterGuard: 'adapter_guard',
    RepeatDelayGuard: 'repeat_delay_guard',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("configurator/#{fp}")) }

  # Apply config from given options.
  def call(options, key: :config)
    case key.to_sym
    when :config
      self.apply_config(options)
    else
      self.configure(key, options)
    end
  end

  # Replace given key value on config (from container) with value from options.
  #
  # @param [String, Symbol] key
  # @param [Hash] options
  #
  # @return [self]
  def configure(key, options)
    self.tap do
      guard_for(key).tap do |guard|
        if options.key?(key.to_sym)
          configure!(key, guard ? guard.call(key, options.dup) : options)
        end
      end
    end
  end

  # Apply `config` option.
  #
  # @param [Hash] options
  def apply_config(options)
    self.tap do
      return self unless options[:config]

      self.config.class.new(options[:config]).tap { |config| with_config(config) }
    end
  end

  protected

  # Get guard for given key.
  #
  # @param [String] key
  #
  # @return [Proc, nil]
  def guard_for(key)
    # @type [Dry::Inflector] inflector
    container.fetch(:inflector).yield_self do |inflector|
      "#{key}_guard".to_sym.yield_self do |m|
        return self.class.const_get(inflector.classify(m)).new
      rescue NameError
        nil
      end
    end
  end

  # @return [IrProxy::Config]
  def config
    # noinspection RubyYardReturnMatch
    container.fetch(:config)
  end

  # Apply given config.
  #
  # @param [IrProxy::Config] config
  #
  # @return [self]
  def with_config(config, &block)
    self.tap do
      container.reset!.set(:config, config.freeze)

      if block
        self.config.dup.tap do |c|
          block.call(c)
          container.reset!.set(:config, c.freeze)
        end
      end
    end
  end

  # Replace given key value on config (from container) with value from options.
  #
  # @param [String, Symbol] key
  # @param [Hash] options
  #
  # @return [self]
  def configure!(key, options)
    self.tap do
      if options.key?(key.to_sym)
        with_config(self.config) { |config| config[key.to_sym] = options[key.to_sym] }
      end
    end
  end
end
