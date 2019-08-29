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
  class Command < Thor
  end
end

# Describe main CLI.
#
# Mostly an entry-point for CLI.
class IrProxy::Cli::Command
  desc('pipe', 'React to STDIN events')

  # React to event received through (CLI) given STDIN pipe.
  #
  # @return [void]
  def pipe
    process { IrProxy::Pipe.new.tap(&:call) }
  end

  desc('sample', 'Print samples on STDOUT')

  # Print samples periodically on STDOUT.
  #
  # @return [void]
  def sample
    IrProxy[:sampler].tap(&:call)
  end

  protected

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
