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
    EventDispatcher: 'event_dispatcher',
    Pipe: 'pipe',
    Sampler: 'sampler'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("ir_proxy/#{fp}")) }
  # @formatter:on

  if bundled?
    require 'bundler/setup'

    if Gem::Specification.find_all_by_name('kamaze-project').any?
      require 'kamaze/project/core_ext/pp'
    end
  end
end
