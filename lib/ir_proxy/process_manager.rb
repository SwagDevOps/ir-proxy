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

  # @param [String] args
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

  # @type [Hash{String => String}]
  attr_accessor :env

  def initialize
    self.pids = []
    self.env = ENV.to_h.freeze
  end

  # @return [Thread]
  def thread
    Thread.abort_on_exception = true

    Thread.new(&Proc.new)
  end

  # @param [String] args
  def sh(*args)
    Shell.sh(*args.push(env))
  end
end
