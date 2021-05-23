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

  {
    VERSION: 'version',
    Adapter: 'adapter',
    Bundleable: 'bundleable',
    Cli: 'cli',
    Clock: 'clock',
    Config: 'config',
    Container: 'container',
    Events: 'events',
    FileLock: 'file_lock',
    KeyScan: 'key_scan',
    KeyTable: 'key_table',
    Logger: 'logger',
    Pipe: 'pipe',
    ProcessManager: 'process_manager',
    Sampler: 'sampler'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("ir_proxy/#{fp}")) }

  include(Bundleable)

  class << self
    # @return [Container]
    def container
      # noinspection RubyYardReturnMatch
      @container ||= Container.instance.tap do |container|
        services.each { |k, v| container.set(k, v) } if container.empty?
      end
    end

    # Retrieve instance stored on container.
    #
    # @param [String|Symbol] id
    #
    # @return [Object]
    def [](id)
      # noinspection RubyYardReturnMatch
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
end
