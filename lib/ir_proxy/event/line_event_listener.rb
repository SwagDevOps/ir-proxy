# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../event'

# Intercept and process lines
class IrProxy::Event::LineEventListener
  # @param [String] line
  def call(line)
    scan(line).tap do |event|
      if !event.empty? and event.down?
        pp(event)
      end
    end
  end

  protected

  # @return [IrProxy::KeyScan]
  def scan(line)
    IrProxy::KeyScan.new(line)
  end
end
