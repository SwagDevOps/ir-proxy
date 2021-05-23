# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Almost namespace for listeners
module IrProxy::Events
  {
    Dispatcher: 'dispatcher',
    HasLogger: 'has_logger',
    Listener: 'listener',
    LineIncoming: 'line_incoming',
    KeyDown: 'key_down',
  }.each { |s, fp| autoload(s, "#{__dir__}/events/#{fp}") }

  class << self
    def register
      IrProxy[:events_dispatcher].tap do |events_dispatcher|
        # @type [IrProxy::Events::Dispatcher] events_dispatcher
        events_dispatcher.listen(listeners)
      end
    end

    # Find listeners from container.
    #
    # @return [Hash{Symbol => Listener|Object}]
    def listeners
      IrProxy.container.keys.map do |id|
        if /^events:/ =~ id.to_s
          [id.to_s.gsub(/^events:/, '').to_sym, IrProxy[id]]
        end
      end.compact.to_h
    end
  end
end
