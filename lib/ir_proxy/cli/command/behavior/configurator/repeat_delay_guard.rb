# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../configurator'

# Guard for repeat_delay option.
class RepeatDelayGuard
  include IrProxy::Concern::ContainerAware

  # @param [Symbol] key
  # @param [Hash{Symbol => Object}] options
  #
  # @return [Hash{Symbol => Object}]
  def call(key, options)
    options.tap { options[key] = options[key]&.abs }
  end
end
