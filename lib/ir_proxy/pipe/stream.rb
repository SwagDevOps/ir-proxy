# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../pipe'

# Read from ``STDIN``
class IrProxy::Pipe::Stream
  autoload(:Fcntl, 'fcntl')

  def initialize(io, io_mode = nil)
    @io = io
    @buffer = []
    # @formatter:off
    (io_mode || Fcntl::O_NDELAY | Fcntl::O_NONBLOCK | Fcntl::O_RDONLY)
      .tap { |v| @io_mode = v }
    # @formatter:on
  end

  def listen
    io.sync = true
    io.fcntl(Fcntl::F_SETFL, io_mode)

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

  # @return [Fixnum]
  attr_reader :io_mode
end
