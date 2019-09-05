# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'
require 'logger'

# Provide logging facility.
class IrProxy::Logger < ::Logger
  attr_reader :progname

  def initialize(*args, **kwargs)
    super
    @progname = kwargs[:progname]
    self.formatter = make_formatter
  end

  protected

  def make_formatter
    # @formatter:off
    proc do |severity, datetime, progname, msg|
      [
        datetime.strftime('%Y-%m-%d %H:%M:%S.%6N'),
        severity[0],
        "#{progname}[#{Process.pid}]:",
        "#{msg}\n"
      ].join(' ')
    end
    # @formatter:on
  end
end