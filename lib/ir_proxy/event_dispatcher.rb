# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Singleton EventDispatcher.
#
# @see IrProxy::EventDispatcher::Dispatcher
class IrProxy::EventDispatcher
  # @formatter:off
  {
    Dispatcher: 'dispatcher',
  }.each { |s, fp| autoload(s, "#{__dir__}/event_dispatcher/#{fp}") }
  # @formatter:on

  def initialize
    @dispatcher = Dispatcher.new
  end

  # Connect listeners to the dispatcher
  #
  # @return [self]
  def listen(**kwargs)
    self.tap { dispatcher.listen(**kwargs) }
  end

  def dispatch(event_name, *args)
    self.tap { dispatcher.dispatch(event_name, *args) }
  end

  protected

  # @return [IrProxy::EventDispatcher::Dispatcher]
  attr_reader :dispatcher
end
