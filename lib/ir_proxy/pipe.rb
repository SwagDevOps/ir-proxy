# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Process input read from ``STDIN``
class IrProxy::Pipe
  # @formatter:off
  {
    Stream: 'stream',
  }.each { |s, fp| autoload(s, "#{__dir__}/pipe/#{fp}") }
  # @formatter:on

  # @param [Hash{Symbol => Object}] kwargs
  def initialize(**kwargs)
    @stream = Stream.new(kwargs[:stream] || $stdin)
    @event_dispatcher = kwargs[:event_dispatcher] || IrProxy[:event_dispatcher]
  end

  def call
    Thread.new do
      stream.listen do |line|
        event_dispatcher.dispatch(:'line.incoming', line)
      end
    end.join
  end

  protected

  # @return [Stream]
  attr_reader :stream

  # @return [IrProxy::EventDispatcher]
  attr_reader :event_dispatcher
end
