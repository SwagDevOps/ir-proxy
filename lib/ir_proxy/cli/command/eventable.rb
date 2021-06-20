# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../command'

# Command starts an events dispatcher.
module IrProxy::Cli::Command::Eventable
  include(IrProxy::Cli::Command::ContainerAware)

  protected

  # @return [IrProxy::EVents::Dispatcher]
  def events_dispatcher
    container.get(:events_dispatcher)
  end

  def eventable(&block)
    events_dispatcher.boot unless events_dispatcher.booted?

    block.call
  end
end
