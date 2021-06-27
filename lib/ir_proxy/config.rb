# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'

# Provide config access
class IrProxy::Config
  autoload(:Pathname, 'pathname')
  autoload(:XDG, 'xdg')
  autoload(:YAML, 'yaml')

  {
    Defaults: 'defaults',
    File: 'file',
  }.each { |s, fp| autoload(s, "#{__dir__}/config/#{fp}") }

  class << self
    include IrProxy::Concern::ContainerAware

    # Get default config values.
    #
    # @return [Hash{Symbol => Object}]
    def defaults
      Defaults.to_h
    end

    # Get path to default config file.
    #
    # @return [Pathname]
    def default_file
      Pathname.new(XDG['CONFIG_HOME'].to_s).join(container.get(:progname), 'config.yml')
    end
  end

  # @param [String. nil] file
  def initialize(file, **options)
    @loaded = nil
    @file = file.freeze
    @options = options.freeze
  end

  # Denote current used file is the default file.
  #
  # @return [Boolean]
  def default_file?
    @file.to_s == default_file.to_s
  end

  # Get options used to read file.
  #
  # @return [Hash]
  def options
    # noinspection RubyYardReturnMatch
    {
      true => { optional: true }.dup.merge(@options),
      false => @options,
    }.fetch((default_file? and !Pathname(@file).exist?))
  end

  # @return [IrProxy::Config::File]
  def file
    IrProxy::Config::File.new(@file, **options)
  end

  # Get path to the config directory.
  #
  # @return [Pathname]
  def path
    Pathname.new(self.file).dirname.expand_path
  end

  # @return [String]
  def to_path
    path.to_s
  end

  # @return [String]
  def to_s
    file.to_s
  end

  alias to_str to_s

  # @return [Hash]
  def to_h
    self.class.defaults.to_h.merge(self.loaded.clone)
  end

  # Get a string representation for config (compatible).
  #
  # @return [String]
  def dump
    self.to_h
        .transform_keys(&:to_s)
        .reject { |k, _| k.to_s =~ /^(imports)$/ }
        .to_h
        .yield_self { |h| YAML.dump(h) }
  end

  # @param [String, Symbol] key
  #
  # @return [Object]
  def [](key)
    self.to_h[key]
  end

  # Set given `key` to given `value`.
  #
  # @param [String|Symbol] key
  # @param [Object] value
  # @return [Object]
  def []=(key, value)
    value.tap do
      self.to_h.dup.tap do |loaded|
        loaded[key] = value
        @loaded = loaded.clone.freeze
      end
    end
  end

  # @return [self]
  def freeze
    self.tap do
      unless self.frozen?
        loaded.tap { @loaded.freeze }
        super
      end
    end
  end

  protected

  # @return [Hash]
  def loaded
    @loaded = file.parse if @loaded.nil?

    @loaded
  end

  # @return [Pathname]
  def default_file
    self.class.default_file
  end
end
