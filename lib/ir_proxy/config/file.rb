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
    super(Pathname.new(path).file? ? Pathname.new(path).expand_path.realpath.to_path : path).tap do
      self.optional = !!(options[:optional])
    end.freeze
  end

  # Denote file is optional
  #
  # @return [Boolean]
  def optional?
    self.optional
  end

  # Read (and parse) config file.
  #
  # @return [Hash{Symbol => Object}]
  def parse
    yaml_read.yield_self { |c| transform(c) }
  end

  protected

  # @return [Boolean]
  attr_accessor :optional

  # @param [Hash{String => Object}] config
  def transform(config)
    config.transform_keys(&:to_sym).tap do |c|
      c.fetch(:imports, {}).each { |k, fp| c[k.to_sym] = yaml(fp) }
      c.fetch(:adapters, {}).each do |name, adapters|
        keymap = adapters&.fetch('keymap', nil)

        c[:adapters][name]['keymap'] = yaml(keymap) if keymap.is_a?(String)
      end
    end
  end

  # @return [Hash{String => Object}]
  def yaml_read
    yaml(self.to_path)
  rescue Errno::ENOENT => e
    return {} if optional?

    raise e
  end

  # @param [String] filepath
  #
  # @return [Object]
  def yaml(filepath)
    self.dup.dirname.yield_self do |dir|
      (Pathname.new(filepath).absolute? ? Pathname.new(filepath) : dir.join(filepath)).freeze
    end.yield_self do |file|
      YAML.safe_load(file.read, [], [], true).yield_self do |parsed|
        # reject extensions
        parsed.reject { |k, _| k.to_s =~ /^x-(.+)/ }.to_h
      end
    end
  end
end
