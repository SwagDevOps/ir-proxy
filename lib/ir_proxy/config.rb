# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
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

  # @param [String. nil] file
  def initialize(file = nil, **options)
    @progname = options[:progname] || IrProxy[:progname]
    @file = file
    @loaded = nil
    @options = options
  end

  # @return [String]
  attr_reader :progname

  # @return [IrProxy::Config::File]
  def file
    IrProxy::Config::File.new(@file || default_file, **@options)
  end

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
    Defaults.to_h.merge(self.loaded.clone)
  end

  def to_yaml
    YAML.dump(self.to_h)
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
    Pathname.new(XDG['CONFIG_HOME'].to_s).join(progname, 'config.yml')
  end
end
