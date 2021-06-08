# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../config'

# Default config values
module IrProxy::Config::Defaults
  class << self
    # @return [Hash{Symbol => Object}]
    def to_h
      {
        protocol: nil,
        repeat_delay: 0.3,
        logger: true,
        adapter: 'dummy',
        adapters: {},
      }
    end
  end
end
