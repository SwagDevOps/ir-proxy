# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Provide dummy adapter (does nothing).
class IrProxy::Adapter::Dummy < IrProxy::Adapter::Adapter
  self.executable = nil

  def command_for(_)
    nil
  end

  def call(keyscan)
    dump(keyscan)
  end

  protected

  def dump(*dumpables)
    dumpables.tap { pp(*dumpables) if dump? }
  end

  def dump?
    !!config.fetch('dump', false)
  end
end
