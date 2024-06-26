# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../concern'

# Can directly access to the container.
module IrProxy::Concern::ContainerAware
  protected

  # Get container access.
  #
  # @return [IrProxy::Container]
  def container
    @container || IrProxy.container
  end
end
