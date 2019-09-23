# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'
require 'timeout'

# Process manager (using forked processes).
#
# Sample of use:
#
# ```ruby
# IrProxy::ProcessManager.new(true) do |pm|
#   pm.call('sleep', '20')
#   pm.call('sleep', '20')
#   pm.call('sleep', '20')
# end
# ```
class IrProxy::ProcessManager
  # @formatter:off
  {
    Shell: 'shell',
    State: 'state',
  }.each { |s, fp| autoload(s, "#{__dir__}/process_manager/#{fp}") }
  # @formatter:on

  def initialize(**kwargs, &block)
    self.env = ENV.to_h.freeze
    self.state = State.new(timeout: 5)
    self.managed = !!(kwargs[:managed])
    self.terminated = false
    self.terminating = false

    @logger = kwargs[:logger]

    yield(handle(&block)) if block
  end

  # Get the process group ID.
  #
  # @return [Integer]
  def pgid
    state.pgid
  end

  # Execute given `args` as subprocess command line.
  #
  # @param [String] args
  # @return [self]
  def call(*args)
    self.tap { sh(*args) }
  end

  # Execute given `args` as command line (``system``).
  #
  # @return [Integer|nil]
  def sh(*args)
    fork { shell.call(*args) }.tap do |pid|
      if pid
        Process.detach(pid)
        self.state.push(pid)
      end
    end
  end

  # Denote manager is managed.
  #
  # @return [Boolean]
  def managed?
    self.managed
  end

  # Manage given block.
  #
  # @yield [ProcessManager]
  def handle(**kwargs)
    self.managed = true if kwargs[:managed]
    yield(self)

    sleep(0.05) until state.clean.empty?
    exit(0) if self.managed?
  end

  # @return [Boolean]
  def terminated?
    self.terminated
  end

  # @return [Boolean]
  def terminating?
    self.terminating
  end

  # Terminate process and subprocesses.
  #
  # @param [Fixnum] status
  #
  # @return [self]
  def terminate(status = 0)
    return self if self.terminated? || self.terminating?

    self.terminating = true
    sleep(0.5)
    self.terminate_warn(status).abort(status)
  end

  protected

  # @return [IrProxy::Logger|Logger]
  attr_reader :logger

  # @return [Hash{String => String}]
  attr_accessor :env

  # @return [State]
  attr_accessor :state

  # @return [Boolean]
  attr_reader :managed

  # @return [Boolean]
  attr_accessor :terminated

  # @return [Boolean]
  attr_accessor :terminating

  # @return [self]
  def terminate_warn(status)
    # rubocop:disable Style/RescueStandardError
    self.tap do
      { pid: $PROCESS_ID, status: status }.tap do |str|
        logger.warn("terminating #{str}...")
      rescue
        warn("terminating #{str}...")
      end
    end
    # rubocop:enable Style/RescueStandardError
  end

  def abort(status = 0)
    self.terminating = true
    state.clear
    exit(status) if self.managed?
  rescue Timeout::Error
    Process.kill(:HUP, -self.pgid) if self.managed?
  ensure
    self.terminated = true
  end

  # Set running (and prepare instance to assume its role).
  #
  # @param [Boolean] flag
  def managed=(flag)
    # noinspection RubySimplifyBooleanInspection
    (!!flag).tap do |managed|
      return self.managed if managed? or !managed

      [:SIGINT, :INT, :TERM].each do |sign|
        Signal.trap(sign) { self.terminate }
      end

      @managed = managed
    end
  end

  # @return [Shell]
  def shell
    Shell.new(env)
  end
end
