# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../event_dispatcher'

# Dispatcher.
class IrProxy::EventDispatcher::Dispatcher
  def initialize(**kwargs)
    @listeners = {}

    listen(**kwargs)
  end

  def listen(**kwargs)
    self.tap do
      kwargs.each do |evenet_name, listener|
        self.add_listener(evenet_name, listener)
      end
    end
  end

  # Denote the given event hash listeners.
  def listeners?(event_name)
    event_name.to_sym.tap do |key|
      return (listeners.key?(key) and !listeners[key].empty?)
    end
  end

  # Notify all listeners for given event.
  #
  # The event instance is then passed to each listener of that event.
  #
  # @param [String|Symbol] event_name
  # @parm [Object] event
  #
  # @return [Boolean]
  def dispatch(event_name, event)
    true.tap do
      self.listeners[event_name].to_a.each do |listener|
        listener.call(event).tap do |result|
          return false if result.is_a?(FalseClass)
        end
      end
    end
  end

  protected

  # @type [Hash{Symbol => Object}]
  attr_accessor :listeners

  # Connect a listener to be notified when an event is dispatched.
  def add_listener(event_name, listener)
    event_name.to_sym.tap do |key|
      self.tap do
        self.listeners[key] = self.listeners[key].to_a.tap do |listeners|
          listeners.push(listener).sort_by do |item|
            (item.respond_to?(:priority) ? item.priority : 0).to_i
          end
        end
      end
    end
  end
end
