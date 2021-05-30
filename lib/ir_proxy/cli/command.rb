# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
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
    }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("command/#{fp}")) }
  end
end

# Describe available commands.
class IrProxy::Cli::Command
  include(Behavior)

  desc('pipe', 'React to STDIN events')
  option(:config, type: :string)
  option(:adapter, type: :string)

  # rubocop:disable Metrics/ParameterLists

  def initialize(args = nil, options = nil, config = nil, container = nil)
    super(args, options, config).tap do
      @container = container || IrProxy.container
    end
  end

  # rubocop:enable Metrics/ParameterLists

  # React to event received through (CLI) given STDIN pipe.
  #
  # @return [void]
  def pipe
    on_pipe(options) { IrProxy::Pipe.new.tap(&:call) }
  end

  desc('config', 'Display config')
  option(:config, type: :string)

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

  protected

  # Get container access.
  #
  # @return [IrProxy::Container]
  attr_reader :container
end
