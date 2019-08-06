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
# IrProxy::ProcessManager.manage do |pm|
#   pm.call('sleep', '20')
#   pm.call('sleep', '20')
#   pm.call('sleep', '20')
# end
# ```
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

  class << self
    # Manage given block.
    #
    # @yield [ProcessManager]
    def manage(&block)
      yield(self.handle(&block))
    end

    # @yield [ProcessManager]
    def handle(managed = true)
      self.instance.__send__('managed=', managed)

      yield(self.instance)

      self.instance.__send__(:state).tap do |state|
        sleep(0.05) until state.clean.empty?
        exit(0) if self.instance.managed?
      end
    end

    # @!attribute instance
    #   @return [IrProxy::ProcessManager]
  end

  # Terminate process and subprocesses.
  #
  # @return [self]
  def terminate
    self.tap do
      warn("Terminating (#{$PROCESS_ID})...")
      self.state.clear
      exit(0) if self.managed?
    rescue Timeout::Error
      Process.kill(:HUP, -self.pgid) if self.managed?
    end
  end

  protected

  # @return [Hash{String => String}]
  attr_accessor :env

  # @return [State]
  attr_accessor :state

  # @return [Boolean]
  attr_reader :managed

  def initialize
    self.env = ENV.to_h.freeze
    self.state = State.new(timeout: 5)
    self.managed = false
  end

  # Set running (and prepare instance to assume its role).
  #
  # @param [Boolean] flag
  def managed=(flag)
    # noinspection RubySimplifyBooleanInspection
    (!!flag).tap do |managed|
      if !managed? and managed
        [:INT, :TERM].each do |sign|
          Signal.trap(sign) { self.terminate }
        end

        @managed = managed
      end
    end
  end

  # @return [Shell]
  def shell
    Shell.new(env)
  end
end
