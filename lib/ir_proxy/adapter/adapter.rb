# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../adapter'

# Base adapter to perform keyboard input.
#
# @abstract
class IrProxy::Adapter::Adapter
  # @return [String]
  attr_reader :executable

  def initialize(**kwargs)
    @executable = kwargs[:executbale] || self.class.executable
    @config = kwargs[:config]
    (kwargs[:process_manager] || IrProxy[:process_manager]).tap do |pm|
      @process_manager = pm
    end
  end

  # Get mapping for given key name.
  #
  # @return [String|nil]
  def trans(key_name)
    (config[:keymap] || {}).fetch(key_name.to_s, nil).tap do |v|
      return v.nil? ? nil : v.to_s
    end
  end

  # Get a command line for given key name.
  #
  # @todo actual implementation
  #
  # @return [Array<String>]
  def command_for(key_name)
    trans(key_name).tap do |input|
      return nil if input.nil?

      return [input.to_s]
    end
  end

  protected

  # @return [IrProxy::ProcessManager]
  attr_reader :process_manager

  # @return [IrPoxy::Config]
  def config
    @config ||= IrProxy[:config]
  end

  class << self
    attr_accessor :executable
  end
end
