# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Almost namespace for listeners
module IrProxy::Events
  # @formatter:off
  {
    LineIncoming: 'line_incoming',
  }.each { |s, fp| autoload(s, "#{__dir__}/events/#{fp}") }
  # @formatter:on

  class << self
    def included(_othermod)
      self.register
    end

    protected

    def register
      # @formatter:off
      {
        'line.incoming': LineIncoming.new,
      }.tap { |events| dispatcher.listen(events) }
      # @formatter:on
    end

    # @return [IrProxy::EventDispatcher.]
    def dispatcher
      IrProxy::EventDispatcher.instance
    end
  end
end
