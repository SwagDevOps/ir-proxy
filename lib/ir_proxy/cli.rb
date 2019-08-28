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

  def call(given_args = ARGV)
    Command.start(given_args.clone)
  end
end
