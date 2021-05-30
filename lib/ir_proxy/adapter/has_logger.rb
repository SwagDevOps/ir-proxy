# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Provide logger.
module IrProxy::Adapter::HasLogger
  protected

  def logger?
    !logger.nil?
  end

  # @return []IrProxy::Logger, nil]
  def logger
    @logger
  end

  def log(message, **kwargs)
    logger&.yield_self do
      Thread.new { logger.public_send(kwargs[:severity] || :debug, message) }
    end
  end
end
