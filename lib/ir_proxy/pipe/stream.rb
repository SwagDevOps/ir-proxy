# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../pipe'

# Read from ``STDIN``
class IrProxy::Pipe::Stream
  def initialize(io)
    @io = io
    @buffer = []
  end

  def listen
    io.sync = true
    until io.eof
      io.read_nonblock(1).tap { |char| buffer.push(char) }

      yield(line) if buffer[-1] == "\n"
    end
  rescue IO::EAGAINWaitReadable
    retry
  end

  protected

  # Get line on completion
  #
  # @return [String]
  def line
    buffer.join('').chomp.tap { buffer.clear }
  end

  # @return [IO]
  attr_reader :io

  # Store buffer as an array of strings/chars
  #
  # @return [Array<String>]
  attr_reader :buffer
end
