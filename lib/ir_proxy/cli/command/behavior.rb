# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Provides command behavior surrounding command execution.
module IrProxy::Cli::Command::Behavior
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

  # @param [String] command_name
  # @param [Hash] options
  # @param [Array<String|Symbol>] appliables
  def on_start(command_name, options, appliables = [], &block)
    appliables.to_a.each { |m| self.__send__("apply_#{m}", options) }

    [:config].each { |k| IrProxy[k].freeze }

    if command_name.to_sym == :pipe
      process { block.call }
    else
      block.call
    end
  end

  # Apply `config` option.
  #
  # @param [Hash] options
  def apply_config(options)
    self.tap do
      if options[:config]
        IrProxy::Config.new(options[:config]).tap do |config|
          IrProxy.container.set(:config, config)
        end
      end
    end
  end

  # Apply `adapter` option.
  #
  # @param [Hash] options
  def apply_adapter(options)
    self.tap do
      if options[:adapter]
        IrProxy[:config][:adapter] = { 'name' => options[:adapter] }
      end
    end
  end

  # Execute given block surrounded by proces manager.
  #
  # @return [void]
  def process(&block)
    0.tap do |status|
      IrProxy[:process_manager].handle(managed: true) do |manager|
        block.call
      rescue SystemExit => e
        status = e.status
      ensure
        manager.terminate(status)
      end
    end
  end
end
