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
  autoload(:XDG, 'xdg')
  autoload(:YAML, 'yaml')

  # @param [String] path
  def initialize(path = nil, **options)
    self.optional = !!(options[:optional])
    (path || lambda do
      Pathname.new(XDG['CONFIG_HOME'].to_s)
          .join(Sys::Proc.progname, 'config.yml')
    end.call).tap { |fp| super(fp) }
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

  # @ertrun [Boolean]
  attr_accessor :optional
end
