# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Provide config access
class IrProxy::Adapter::Xdotool < IrProxy::Adapter::Adapter
  self.executable = 'xdotool'

  def command_for(key_name)
    super.tap do |input|
      return nil if input.nil?

      # @formatter:off
      return [executable]
             .append('key')
             .append(*adapter_config['options'].to_a.map(&:to_s))
             .append(*input)
      # @formatter:off
    end
  end
end
