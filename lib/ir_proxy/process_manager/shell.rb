# frozen_string_literal: true

# Copyright (C) 2018-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../process_manager'

# Shell used by process manager.
class IrProxy::ProcessManager::Shell
  # @type [Hash]
  attr_reader :env

  def initialize(env = {})
    @env = ENV.to_h.merge(env).clone.freeze
  end

  # @return [Boolean|nil]
  def call(*args)
    self.exec(*args)
  end

  class << self
    # @return [Boolean|nil]
    def exec(*args)
      [{}, args.clone].tap do |env, cmd|
        if args.size > 1 and args[-1].is_a?(Hash)
          env = args[-1]
          cmd = args[0..-2]
        end

        return self.new(env).call(*cmd)
      end
    end
  end

  protected

  # Run command.
  #
  # @param [String] args
  #
  # @return [Boolean|nil]
  # @raise [RuntimeError]
  def exec(*args)
    Kernel.exec(env, *args)
  end

  def system(*args)
    Kernel.system(env, *args) || lambda do
      $CHILD_STATUS.tap do |stt|
        raise "#{args.inspect} (#{stt.to_i})"
      end
    end.call
  rescue Interrupt
    nil
  end
end
