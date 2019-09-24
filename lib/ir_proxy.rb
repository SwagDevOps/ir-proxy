# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Base module (namespace)
module IrProxy
  autoload(:Pathname, 'pathname')

  class << self
    protected

    # Denote current class is used in a bundled context.
    #
    # @return [Boolean]
    def bundled?
      # @formatter:off
      [['gems.rb', 'gems.locked'], ['Gemfile', 'Gemfile.lock']].map do |m|
        Dir.chdir("#{__dir__}/..") do
          m.map { |f| Pathname(f).file? }.uniq
        end
      end.include?([true])
      # @formatter:on
    end

    # Denote current class is used in development context.
    #
    # @return [Boolean]
    def development?
      # @formatter:off
      [['gemspec.tpl']].map do |m|
        Dir.chdir("#{__dir__}/..") do
          m.map { |f| Pathname(f).file? }
        end
      end.include?([true])
      # @formatter:on
    end
  end

  # @formatter:off
  {
    VERSION: 'version',
    Adapter: 'adapter',
    Cli: 'cli',
    Config: 'config',
    Container: 'container',
    Events: 'events',
    FileLock: 'file_lock',
    KeyScan: 'key_scan',
    Logger: 'logger',
    Pipe: 'pipe',
    ProcessManager: 'process_manager',
    Sampler: 'sampler'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("ir_proxy/#{fp}")) }
  # @formatter:on

  if bundled?
    require 'bundler/setup'
  end

  if development?
    require 'pp'
    require 'kamaze/project/core_ext/pp'
  end

  class << self
    # @return [Container]
    def container
      @container ||= Container.instance.tap do |container|
        if container.empty?
          services.each { |k, v| container.set(k, v) }
        end
      end
    end

    # @param [String|Symbol] id
    #
    # @return [Object]
    def [](id)
      container.get(id)
    end

    protected

    def services
      require 'sys/proc'
      require 'English'

      Pathname.new(__FILE__.gsub(/\.rb$/, '')).join('services.rb').tap do |file|
        return instance_eval(file.read, file.to_s, 1)
      end
    end
  end

  include IrProxy::Events
end
