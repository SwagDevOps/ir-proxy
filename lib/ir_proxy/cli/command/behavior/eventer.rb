# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# Command starts an events dispatcher.
class IrProxy::Cli::Command::Behavior::Eventer
  include(IrProxy::Concern::ContainerAware)

  def call(&block)
    events_dispatcher.boot unless events_dispatcher.booted?

    block.call
  end

  class << self
    def call(&block)
      self.new.call(&block)
    end
  end

  protected

  # @return [IrProxy::EVents::Dispatcher]
  def events_dispatcher
    self.container.get(:events_dispatcher)
  end
end
