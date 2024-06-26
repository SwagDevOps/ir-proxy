# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Provide adapters access
#
# Act as a factory, where target is implicit and based on ``config``.
class IrProxy::Adapter
  {
    Adapter: 'adapter',
    Dummy: 'dummy',
    HasLogger: 'has_logger',
    Xdotool: 'xdotool',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("adapter/#{fp}")) }

  class << self
    # Get an instance of adapter.
    #
    # @return [IrProxy::Adapter::Adapter]
    def instance(**kwargs)
      (kwargs[:config] || IrProxy[:config]).to_h.yield_self do |config|
        lambda do
          config.fetch(:adapter, nil).tap do |v|
            return v.transform_keys(&:to_sym)[:name] if v.is_a?(Hash)
          end
        end.call
      end.yield_self { |name| self.fetch(name&.to_sym) }
    end

    # Denote given key is available.
    #
    # @return [Boolean]
    def has?(key)
      self.keys.include?(key.to_sym)
    end

    # @return [Array<Symbol>]
    def keys
      self.adapters.keys.sort
    end

    protected

    def [](key)
      adapters[key]
    end

    def fetch(*args)
      adapters.fetch(*args)
    end

    # Retrieve adapters stored on container.
    #
    # @return [Hash{Symbol => IrProxy::Adapter::Adapter}]
    def adapters
      IrProxy.container.keys.sort.map do |id|
        /^adapters:/.yield_self { |reg| [id.to_s.gsub(reg, '').to_sym, IrProxy[id]] if reg =~ id.to_s }
      end.compact.to_h
    end
  end
end
