# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../configurator'

# Guard for adpater option.
class AdapterGuard
  include IrProxy::Concern::ContainerAware

  # @param [Symbol] key
  # @param [Hash{Symbol => Object}] options
  #
  # @raise Thor::Error
  #
  # @return [Hash{Symbol => Object}]
  def call(key, options)
    options.tap do
      "ERROR: #{key} must be in {#{adapter_factory.keys.map(&:to_s).join('|')}}".yield_self do |message|
        unless adapter_factory.has?(options.fetch(:adapter).to_sym)
          raise Thor::Error, message
        end
      end
    end
  end

  protected

  # @return [Class<IrProxy::Adapter>]
  def adapter_factory
    # noinspection RubyYardReturnMatch
    container.fetch('adapter.factory')
  end
end
