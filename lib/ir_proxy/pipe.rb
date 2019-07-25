# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Process input read from ``STDIN``
class IrProxy::Pipe
  # @formatter:off
  {
    Stream: 'stream',
  }.each { |s, fp| autoload(s, "#{__dir__}/pipe/#{fp}") }
  # @formatter:on

  def initialize(stream = $stdin)
    @stream = Stream.new(stream)
  end

  def call
    Thread.new do
      stream.listen { |line| process_line(line) }
    end.join
  end

  protected

  # @tddo write real implementation
  def process_line(line)
    $stdout.puts(line)
  end

  # @return [Stream]
  attr_reader :stream

  # @return [Array<String>]
  attr_reader :buffer
end
