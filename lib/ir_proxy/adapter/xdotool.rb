# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Provide config access
class IrProxy::Adapter::Xdotool < IrProxy::Adapter::Adapter
  autoload(:Shellwords, 'shellwords')

  self.executable = 'xdotool'

  # @return [String, nil]
  #
  # @see #command_base
  # @see #with
  def command_for(key_name)
    with(super) do |command|
      command.to_s.tap do |s|
        log("command: #{s.inspect}", severity: :debug)
      end
    end
  end

  protected

  # Get command options
  #
  # @return [Array<String>]
  def command_options
    config['options'].to_a.map(&:to_s)
  end

  # Get base for command.
  #
  # ```ruby
  # [self.executable, 'key', self.command_options]
  # ```
  #
  # @return [Array<String>]
  #
  # @note Returned `Array` has a method `to_s` using `Shellwords.join()` to represent itself as an actual command line.
  def command_base
    [self.executable].append('key').append(*command_options).tap do |command|
      command.define_singleton_method(:to_s) { Shellwords.join(self) }
    end
  end

  # @param [Array<String>, nil] input
  #
  # @yield [Array<String>]
  def with(input, &block)
    input ? command_base.append(*input).tap(&block) : nil
  end
end
