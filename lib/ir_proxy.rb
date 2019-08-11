# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Base module (namespace)
module IrProxy
  require 'English'
  autoload(:Pathname, 'pathname')

  class << self
    protected

    # @return [Boolean]
    def bundled?
      # @formatter:off
      [['gems.rb', 'gems.locked'], ['Gemfile', 'Gemfile.lock']]
        .map { |m| Dir.glob("#{__dir__}/../#{m}").size >= 2 }
        .include?(true)
      # @formatter:on
    end
  end

  # @formatter:off
  {
    VERSION: 'version',
    Cli: 'cli',
    Container: 'container',
    Events: 'events',
    EventDispatcher: 'event_dispatcher',
    FileLock: 'file_lock',
    KeyScan: 'key_scan',
    Pipe: 'pipe',
    ProcessManager: 'process_manager',
    Sampler: 'sampler'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("ir_proxy/#{fp}")) }
  # @formatter:on

  if bundled?
    require 'bundler/setup'

    if Gem::Specification.find_all_by_name('kamaze-project').any?
      require 'kamaze/project/core_ext/pp'
    end
  end

  class << self
    # @return [Container]
    def container
      Container.instance.tap do |container|
        if container.empty?
          services.each { |k, v| container.set(k, v) }

          container.freeze unless container.frozen?
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
      Pathname.new(__FILE__.gsub(/\.rb$/, '')).join('services.rb').tap do |file|
        return instance_eval(file.read)
      end
    end
  end

  include IrProxy::Events
end
