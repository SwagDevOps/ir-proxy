# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Describe main CLI.
#
# Mostly an entry-point for CLI.
class IrProxy::Cli
  # @formatter:off
  {
    Command: 'command',
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("cli/#{fp}")) }
  # @formatter:on

  def initialize(**kwargs)
    @events_dispatcher = kwargs[:events_dispatcher]
  end

  # Execute CLI.
  #
  # @param [Array<String>] given_args
  #
  # @return [void]
  def call(given_args = ARGV)
    events_dispatcher&.boot

    Command.start(given_args.clone)
  end

  protected

  def events_dispatcher
    @events_dispatcher || IrProxy[:events_dispatcher]
  end
end
