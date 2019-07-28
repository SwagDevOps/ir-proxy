# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Process manager (using forked processes).
class IrProxy::ProcessManager
  autoload(:Singleton, 'singleton')
  include Singleton

  # @formatter:off
  {
    Shell: 'shell',
  }.each { |s, fp| autoload(s, "#{__dir__}/process_manager/#{fp}") }
  # @formatter:on

  # @return [Integer]
  def pgid
    Process.getpgid($PROCESS_ID)
  end

  def call(*args)
    self.tap do
      self.thread do
        fork { sh(*args) }.tap { |pid| pids.push(pid) }
      end.join
    end
  end

  # Terminate subprocesses.
  #
  # @return [self]
  def terminate
    Process.kill(:HUP, -self.pgid)

    self
  end

  protected

  # @return [Array<Integer>]
  attr_accessor :pids

  def initialize
    self.pids = []
  end

  def thread
    Thread.abort_on_exception = true

    Thread.new(&Proc.new)
  end

  def sh(*args)
    Shell.sh(*args)
  end
end
