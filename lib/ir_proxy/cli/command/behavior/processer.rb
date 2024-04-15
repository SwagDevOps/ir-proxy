# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# Command is processed with a process manager.
class IrProxy::Cli::Command::Behavior::Processer
  include(IrProxy::Concern::ContainerAware)

  # Execute given block surrounded by proces manager.
  #
  # @return [Integer] return code (exit)
  def call(&block)
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

  class << self
    def call(&block)
      self.new.call(&block)
    end
  end

  protected

  # @return [IrProxy::ProcessManager]
  def process_manager
    # noinspection RubyYardReturnMatch
    self.container.get(:process_manager)
  end
end
