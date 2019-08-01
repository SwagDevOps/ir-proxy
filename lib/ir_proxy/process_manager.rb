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
    State: 'state',
  }.each { |s, fp| autoload(s, "#{__dir__}/process_manager/#{fp}") }
  # @formatter:on

  # Get the process group ID.
  #
  # @return [Integer]
  def pgid
    state.pgid
  end

  # Execute given `args` as subprocess command line.
  #
  # @param [String] args
  # @retunr [self]
  def call(*args)
    self.tap { sh(*args) }
  end

  # Execute given `args` as command line (``system``).
  #
  # @return [Boolean|nil]
  def sh(*args)
    fork { shell.call(*args) }.tap do |pid|
      if pid
        Process.detach(pid)
        self.state.push(pid)
      end
    end
  end

  # Denote manager is runing.
  #
  # @return [Boolean]
  def running?
    self.running
  end

  class << self
    def run
      instance.__send__('running=', true)

      yield(instance)

      instance.__send__(:state).tap do |state|
        sleep(0.1) until state.clean.empty?
        exit(0)
      end
    end
  end

  # Terminate process and subprocesses.
  def terminate
    warn("Terminating (#{$PROCESS_ID})...")
    self.state.clear
    exit(0)
  rescue Timeout::Error
    Process.kill(:HUP, -self.pgid)
  end

  protected

  # @return [Hash{String => String}]
  attr_accessor :env

  # @return [State]
  attr_accessor :state

  # @return [Boolean]
  attr_reader :running

  def initialize
    self.env = ENV.to_h.freeze
    self.state = State.new(timeout: 5)
  end

  # Set running (and prepare instance to assume its role).
  #
  # @param [Boolean] flag
  def running=(flag)
    unless running?
      [:INT, :TERM].each do |sign|
        Signal.trap(sign) { self.terminate }
      end
    end

    # noinspection RubySimplifyBooleanInspection
    @running = !!flag
  end

  # @return [Shell]
  def shell
    Shell.new(env)
  end
end
