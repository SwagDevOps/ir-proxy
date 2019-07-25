# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Process input read from ``STDIN``
class IrProxy::Pipe
  def initialize(stream = $stdin)
    @stream = stream
    @buffer = []
  end

  def call
    stream.sync = true
    Thread.new do
      listen { |line| process_line(line) }
    end.join
  end

  protected

  def listen
    until stream.eof
      char = stream.read_nonblock(1)
      buffer.push(char)
      next if char != "\n"

      line = buffer.join('')
      buffer.clear
      yield(line)
    end
  rescue IO::EAGAINWaitReadable
    retry
  end

  # @tddo write real implementation
  def process_line(line)
    $stdout.puts(line)
    $stdout.flush
  end

  # @return [IO]
  attr_reader :stream

  # @return [Array<String>]
  attr_reader :buffer
end
