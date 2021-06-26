# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# Apply configuration
class IrProxy::Cli::Command::Behavior::Configurator
  include IrProxy::Concern::ContainerAware

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
      if options.key?(key.to_sym)
        with_config(self.config) { |config| config[key.to_sym] = options[key.to_sym] }
      end
    end
  end

  # Apply `config` option.
  #
  # @param [Hash] options
  def apply_config(options)
    self.tap do
      return self unless options[:config]

      IrProxy::Config.new(options[:config]).tap { |config| with_config(config) }
    end
  end

  protected

  # @return [IrProxy::Config]
  def config
    # noinspection RubyYardReturnMatch
    container.get(:config)
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
end
