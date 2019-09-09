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
  autoload(:File, "#{__dir__}/config/file")

  # @return [IrProxy::Config::File]
  attr_reader :file

  # @param [String] file
  def initialize(file = nil, **options)
    @progname = options[:progname] || IrProxy[:progname]
    @file = File.new(file || default_file, **options)
    @loaded = nil
  end

  # @return [String]
  def to_s
    file.to_s
  end

  alias to_str to_s

  # @return [Hash]
  def to_h
    loaded.dup
  end

  # @param [String|Symbol] key
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
      Hash.new(@loaded).tap do |loaded|
        @loaded = proc do
          loaded[key] = value
          loaded.clone.freeze
        end.call
      end
    end
  end

  # @return [self]
  def freeze
    self.tap do
      unless self.frozen?
        (@loaded ||= file.parse).tap { @loaded.freeze }
        super
      end
    end
  end

  protected

  # @return [Hash]
  attr_reader :loaded

  # @return [String]
  attr_reader :progname

  # @returm [Pathname]
  def default_file
    Pathname.new(XDG['CONFIG_HOME'].to_s).join(progname, 'config.yml')
  end
end
