# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'
require 'timeout'

# Process manager (using forked processes).
class IrProxy::ProcessManager
  autoload(:Singleton, 'singleton')
  include Singleton

  # @formatter:off
  {
    Shell: 'shell',
  }.each { |s, fp| autoload(s, "#{__dir__}/process_manager/#{fp}") }
  # @formatter:on

  # Get the process group ID.
  #
  # @return [Integer]
  def pgid
    Process.getpgid($PROCESS_ID)
  end

  # Execute given `args` as subprocess command line.
  #
  # @param [String] args
  def call(*args)
    self.clean.tap do
      self.thread do
        fork { sh(*args) }.tap { |pid| pids.push(pid) }
      end.join
    end
  end

  # @return [self]
  def clean
    self.tap do
      self.pids.keep_if { |pid| alive?(pid) }
    end
  end

  class << self
    def call
      yield(instance)

      instance.__send__(:clean).__send__(:pids).tap do |pids|
        until pids.empty?
          sleep(0.1)
          pp(pids)
        end
      end
      exit(0)
    end
  end

  # Execute given `args` as command line (``system``).
  #
  # @return [Boolean|nil]
  def sh(*args)
    shell.call(*args)
  end

  # Terminate process and subprocesses.
  def terminate
    warn("Terminating (#{$PROCESS_ID})...")
    Timeout.timeout(self.terminate_timeout) do
      pids.each { |pid| self.kill(pid) } until clean.pids.empty?
    end
    exit(0)
  rescue Timeout::Error
    Process.kill(:HUP, -self.pgid)
  end

  protected

  # @return [Array<Integer>]
  attr_accessor :pids

  # @type [Hash{String => String}]
  attr_accessor :env

  attr_accessor :terminate_timeout

  def initialize
    self.pids = []
    self.env = ENV.to_h.freeze
    self.terminate_timeout = 5

    [:INT, :TERM].each do |sign|
      Signal.trap(sign) { self.terminate }
    end
  end

  # @return [Thread]
  def thread
    Thread.abort_on_exception = true

    Thread.new(&Proc.new)
  end

  # @return [Boolean]
  def alive?(pid)
    Process.waitpid(pid, Process::WNOHANG) and Process.getpgid(pid) == pgid
  rescue Errno::ESRCH, Errno::ECHILD
    false
  end

  def kill(pid)
    Process.kill(:INT, pid) if Process.getpgid(pid) == pgid
  rescue Errno::ESRCH, Errno::ECHILD
    false
  end

  # @return [Shell]
  def shell
    Shell.new(env)
  end
end
