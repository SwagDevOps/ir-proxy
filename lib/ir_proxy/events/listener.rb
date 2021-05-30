# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# @abstract
class IrProxy::Events::Listener
  # @param [Hash{Symbol => Object}] kwargs
  def initialize(**kwargs)
    kwargs[:events_dispatcher].tap do |events_dispatcher|
      @events_dispatcher = events_dispatcher || IrProxy[:events_dispatcher]
    end
  end

  protected

  # @return [IrProxy::EventDispatcher]
  attr_reader :events_dispatcher
end
