# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Provides command behavior surrounding command execution.
module IrProxy::Cli::Command::Behavior
  include(IrProxy::Cli::Command::Eventable)
  include(IrProxy::Cli::Command::Configurable)
  include(IrProxy::Cli::Command::Processable)

  protected

  # Block surrounding `pipe` command.
  #
  # @param [Hash] options
  def on_pipe(options, &block)
    on_start(:pipe, options, [:config, :adapter], &block)
  end

  # Block surrounding `sample` command.
  #
  # @param [Hash] options
  def on_sample(options, &block)
    on_start(:sample, options, [], &block)
  end

  # @param [Hash] options
  def on_config(options, &block)
    on_start(:config, options, [:config, :adapter], &block)
  end

  # @param [String, Symbol] command_name
  # @param [Hash] options
  # @param [Array<String, Symbol>] appliables
  def on_start(command_name, options, appliables = [], &block)
    appliables.to_a.each { |m| self.__send__("apply_#{m}", options.transform_keys(&:to_sym)) }

    eventable do
      command_name.to_sym == :pipe ? process { block.call } : block.call
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

  # Apply `adapter` option.
  #
  # @param [Hash] options
  def apply_adapter(options)
    self.tap do
      if options[:adapter]
        with_config(app_config) { |config| config[:adapter] = options[:adapter] }
      end
    end
  end
end
