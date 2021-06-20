# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Command is processed with a process manager.
module IrProxy::Cli::Command::Processable
  include(IrProxy::Cli::Command::ContainerAware)

  protected

  # @return [IrProxy::ProcessManager]
  def process_manager
    container.get(:process_manager)
  end

  # Execute given block surrounded by proces manager.
  #
  # @return [Integer] return code (exit)
  def process(&block)
    0.tap do |status|
      process_manager.handle(managed: true) do |manager|
        block.call
      rescue SystemExit => e
        status = e.status
      ensure
        manager.terminate(status)
      end
    end
  end
end
