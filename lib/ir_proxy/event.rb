# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Almost namespace for listeners
module IrProxy::Event
  # @formatter:off
  {
    LineEventListener: 'line_event_listener',
  }.each { |s, fp| autoload(s, "#{__dir__}/event/#{fp}") }
  # @formatter:on

  class << self
    def included(_othermod)
      self.register
    end

    protected

    def register
      dispatcher.listen('line.incoming': LineEventListener.new)
    end

    # @return [IrProxy::EventDispatcher.]
    def dispatcher
      IrProxy::EventDispatcher.instance
    end
  end
end
