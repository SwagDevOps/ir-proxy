# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../config'
require 'sys/proc'
require 'pathname'

# Read config file
class IrProxy::Config::File < Pathname
  autoload(:YAML, 'yaml')

  # @param [String] path
  def initialize(path, **options)
    super(path)
    self.optional = !!(options[:optional])
  end

  def optional?
    self.optional
  end

  # Read (and parse) config file.
  #
  # @return [Hash{Symbol => Object}]
  def parse
    YAML.safe_load(self.read).tap do |h|
      return h.map { |k, v| [k.to_sym, v] }.to_h.freeze
    end
  rescue Errno::ENOENT => e
    return {} if optional?

    raise e
  end

  protected

  # @return [Boolean]
  attr_accessor :optional

  # @return [String]
  attr_accessor :progname
end
