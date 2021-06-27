# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
module IrProxy::Cli::Command::Behavior::HasAppliables
  # @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
  #
  # @@return [Appliables|Hash{Symbol => Hash}]
  def appliables
    self.const_get(:CONFIGURABLE_APPLIABLES).yield_self do |appliables|
      IrProxy::Cli::Command::Behavior::Appliables.new(appliables)
    end
  end

  # @param [Class<Thor>] subject
  #
  # @return [self]
  def apply_on(subject)
    self.tap do
      self.appliables.each { |k, v| subject.option(k, v.to_h) }
    end
  end
end
