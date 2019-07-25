# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Describe main CLI.
#
# Mostly an entry-point for CLI.
class IrProxy::Cli
  def call
    IrProxy::Pipe.new.tap(&:call)

    0
  end

  class << self
    def call
      self.new.call
    end
  end
end
