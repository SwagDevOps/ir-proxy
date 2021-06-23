# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Command is configurable.
#
# As a result app config (stored in container) will be replaced or altered on the container.
module IrProxy::Cli::Command::Configurable
  include(IrProxy::Cli::Command::ContainerAware)

  protected

  # @return [IrProxy::Config]
  def app_config
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
        self.app_config.dup.tap do |c|
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
  def configure(key, options)
    self.tap do
      if options.key?(key.to_sym)
        with_config(app_config) { |config| config[key.to_sym] = options[key.to_sym] }
      end
    end
  end
end
