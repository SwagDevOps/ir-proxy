# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Provides command behavior surrounding command execution.
module IrProxy::Cli::Command::Behavior
  {
    Appliable: 'appliable',
    Appliables: 'appliables',
    Configurator: 'configurator',
    Eventer: 'eventer',
    HasAppliables: 'has_appliables',
    Process: 'process',
    CONFIGURABLE_APPLIABLES: 'configurable_appliables'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("behavior/#{fp}")) }

  class << self
    include(HasAppliables)
  end

  protected

  # @param [Hash] options
  def on_config(options, &block)
    on_start(:config, options, configurable_appliables.keys, &block)
  end

  # Block surrounding `pipe` command.
  #
  # @param [Hash] options
  def on_pipe(options, &block)
    on_start(:pipe, options, configurable_appliables.keys, &block)
  end

  # Block surrounding `sample` command.
  #
  # @param [Hash] options
  def on_sample(options, &block)
    on_start(:sample, options, [], &block)
  end

  # @param [String, Symbol] command_name
  # @param [Hash] options
  # @param [Array<String, Symbol>] appliables
  def on_start(command_name, options, appliables = [], &block)
    Configurator.new.tap do |configurator|
      appliables.to_a.each do |key|
        configurator.call(options, key: key)
      end
    end

    Eventer.call do
      command_name.to_sym == :pipe ? Processer.call { block.call } : block.call
    end
  end

  # @@return [Hash{Symbol => Appliable}]
  def configurable_appliables
    IrProxy::Cli::Command::Behavior.appliables
  end
end
