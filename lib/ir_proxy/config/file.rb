# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
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
      yaml_load_file(file).reject { |k, _| k.to_s =~ /^x-(.+)/ }.to_h # reject extensions
    end
  end
end

# Load given file (with ruby version compat, prior to ruby 3)
#
# Prior to ruby 3:
# ```
# Psych.safe_load(yaml, whitelist_classes = [], whitelist_symbols = [], aliases = false, filename = nil, symbolize_names: false)
# ```
# Modern method:
# ```
# Psych.safe_load(yaml, permitted_classes: [Date], symbolize_names: false, aliases: true)
# ```
#
# @param [Pathname] file
#
# @return [Object]
# @see https://ruby-doc.org/stdlib-3.0.1/libdoc/psych/rdoc/Psych.html#method-c-safe_load
def yaml_load_file(file)
  RUBY_VERSION.split('.').first.to_i.then do |v|
    return YAML.safe_load(file.read, [], [], true) if v < 3

    YAML.safe_load(file.read, aliases: true)
  end
end
