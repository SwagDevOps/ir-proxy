# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../process_manager'

# Internal state for process-manager.
class IrProxy::ProcessManager::State
  autoload(:Concurrent, 'concurrent')
  attr_reader :pids

  def initialize(**kwargs)
    @pids = Concurrent::Array.new
    @timeout = (kwargs[:timeout] || 8).to_i
  end

  # Get the process group ID.
  #
  # @return [Integer]
  def pgid
    Process.getpgid($PROCESS_ID)
  end

  # Remove terminated PIDs.
  #
  # @return [self]
  def clean
    self.pids.keep_if { |pid| alive?(pid) }

    self
  end

  # Clear PIDs (killing them), using a timeout.
  #
  # @return [self]
  #
  # @raise [Timeout::Error]
  def clear
    Timeout.timeout(self.timeout) do
      clean.pids.each { |pid| self.kill(pid) } until pids.empty?
    end

    self
  end

  def push(*args)
    clean.pids.push(*args)

    self
  end

  def empty?
    pids.empty?
  end

  protected

  # @return [Integer]
  attr_reader :timeout

  attr_writer :pids

  # @return [Boolean]
  def alive?(pid)
    # Process.kill(0, pid)
    Process.getpgid(pid) == pgid
  rescue Errno::ESRCH, Errno::ECHILD
    false
  end

  # @return [Boolean]
  def kill(pid)
    Process.kill(:INT, pid) if Process.getpgid(pid) == pgid
  rescue Errno::ESRCH, Errno::ECHILD
    false
  end
end
