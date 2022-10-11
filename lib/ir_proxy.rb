# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

$LOAD_PATH.unshift(__dir__)

# Base module (namespace)
module IrProxy
  {
    VERSION: 'version',
    Adapter: 'adapter',
    Bundleable: 'bundleable',
    Cli: 'cli',
    Clock: 'clock',
    Concern: 'concern',
    Config: 'config',
    Container: 'container',
    Events: 'events',
    FileLock: 'file_lock',
    KeyScan: 'key_scan',
    KeyTable: 'key_table',
    Logger: 'logger',
    Pipe: 'pipe',
    ProcessManager: 'process_manager',
    Sampler: 'sampler',
    SyntaxHighlighter: 'syntax_highlighter',
    Throttler: 'throttler',
  }.each { |s, fp| autoload(s, "#{__dir__}/ir_proxy/#{fp}") }

  include(Bundleable)

  class << self
    # @return [Container]
    def container
      Container.instance
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
  end
end
