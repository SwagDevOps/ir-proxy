# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../config'
require 'pathname'

# Read config file.
#
# ```yaml
# x-defaults: &defaults
#   keymap: 'keymaps/default.yml'
#   dump: true
#
# adapter:
#   name: xdotool
#   <<: *defaults
# ```
class IrProxy::Config::File < Pathname
  autoload(:YAML, 'yaml')

  # @param [String, Pathname] path
  def initialize(path, **options)
    super(path).tap { self.optional = !!(options[:optional]) }.freeze
  end

  def optional?
    self.optional
  end

  # Read (and parse) config file.
  #
  # @return [Hash{Symbol => Object}]
  def parse
    yaml(self.to_path).tap do
    rescue Errno::ENOENT => e
      return {} if optional?

      raise e
    end.transform_keys(&:to_sym).tap do |config|
      config.fetch(:adapter, nil)&.fetch('keymap', nil).tap do |keymap|
        config[:adapter]['keymap'] = yaml(keymap) if keymap.is_a?(String)
      end
    end
  end

  protected

  # @return [Boolean]
  attr_accessor :optional

  # @param [String] filepath
  #
  # @return [Object]
  def yaml(filepath)
    Pathname.new(filepath).yield_self do |file|
      Dir.chdir(self.dup.dirname) { YAML.safe_load(file.read, [], [], true) }.tap do |parsed|
        # reject extensions
        parsed.reject { |k, _| /^x-.+/ =~ k.to_s }.to_h
      end
    end
  end
end
