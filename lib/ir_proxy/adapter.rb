# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Provide config access
class IrProxy::Adapter
  # @formatter:off
  {
    Adapter: 'adapter',
    Xdotool: 'xdotool',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("adapter/#{fp}")) }
  # @formatter:on

  class << self
    # Get an instance of adapter.
    #
    # @return [IrProxy::Adapter::Adapter]
    def instance(**kwargs)
      (kwargs[:config] || IrProxy[:config]).to_h.tap do |config|
        (config.fetch(:adapter, {})['name'] || 'xdotool').to_sym.tap do |k|
          return self.fetch(k)
        end
      end
    end

    protected

    def [](key)
      adapters[key]
    end

    def fetch(*args)
      adapters.fetch(*args)
    end

    # Find listeners from container.
    #
    # @return [Hash{Symbol => Listener|Object}]
    def adapters
      IrProxy.container.keys.map do |id|
        if /^adapters:/ =~ id.to_s
          [id.to_s.gsub(/^adapters:/, '').to_sym, IrProxy[id]]
        end
      end.compact.to_h
    end
  end
end
