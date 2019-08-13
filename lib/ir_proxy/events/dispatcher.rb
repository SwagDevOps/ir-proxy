# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../events'

# Dispatcher.
class IrProxy::Events::Dispatcher
  def initialize(**kwargs)
    @listeners = {}

    listen(**kwargs)
  end

  # Add new listener(s) (by name)
  #
  # Sample of use:
  #
  # ```ruby
  # dispatcher.listen(user_login: UserLoginListener.new)
  # ````
  # @param [Hash{Symbol => Object}] kwargs
  # @option kwargs [Object] * Listener for given `event_name`
  def listen(**kwargs)
    self.tap do
      kwargs.each do |event_name, listener|
        self.add_listener(event_name, listener)
      end
    end
  end

  # Denote the given event hash listeners.
  #
  # @param [String|Symbol] event_name
  #
  # @return [Boolean]
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
  # @param [Object] args atguments passed to `Object#call` listener method
  #
  # @return [Boolean]
  def dispatch(event_name, *args)
    true.tap do
      self.listeners[event_name].to_a.each do |listener|
        listener.call(*args).tap do |result|
          # noinspection RubySimplifyBooleanInspection
          return false if result == false
        end
      end
    end
  end

  def freeze
    listeners.freeze

    super
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
