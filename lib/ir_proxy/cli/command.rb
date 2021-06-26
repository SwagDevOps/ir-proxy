# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'

# @api
class IrProxy::Cli
  autoload(:Thor, 'thor')

  # @api
  class Command < Thor
    {
      Behavior: 'behavior',
      Configurable: 'configurable',
      ContainerAware: 'container_aware',
      Eventable: 'eventable',
      Processable: 'processable',
    }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("command/#{fp}")) }
  end
end

# Describe available commands.
class IrProxy::Cli::Command
  include(Behavior)
  include(IrProxy::Concern::ContainerAware)

  desc('pipe', 'React to STDIN events')
  Behavior.apply_on(self)
  # React to event received through (CLI) given STDIN pipe.
  #
  # @return [void]
  def pipe
    on_pipe(options) { IrProxy::Pipe.new.tap(&:call) }
  end

  desc('config', 'Display config')
  Behavior.apply_on(self)
  # React to event received through (CLI) given STDIN pipe.
  #
  # @return [void]
  def config
    on_config(options) do
      container[:config].dump.tap do |source|
        container[:yaml_highlighter].call(source).tap { |s| puts(s) }
      end
    end
  end

  desc('sample', 'Print samples on STDOUT')
  # Print samples periodically on STDOUT.
  #
  # @return [void]
  def sample
    on_sample(options) { container[:sampler].tap(&:call) }
  end
end
