# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../ir_proxy'
require 'sys/proc'

# Provide file locking (based on `flock`).
class IrProxy::FileLock
  autoload(:XDG, 'xdg')
  autoload(:Digest, 'digest')
  autoload(:FileUtils, 'fileutils')
  autoload(:Pathname, 'pathname')

  # @param [String] filepath
  def initialize(filepath = nil)
    @path = (filepath || default_filepath).to_s
  end

  # Error acquiring lock.
  class LockError < RuntimeError
  end

  # @return [String]
  def to_s
    self.path
  end

  def lock!(&block)
    self.path.tap do |fp|
      FileUtils.mkdir_p(Pathname.new(fp).dirname.to_s)
      File.open(fp, File::CREAT).tap do |lock|
        # returns false if already locked, 0 if not
        lock.flock(File::LOCK_EX | File::LOCK_NB).tap do |ret|
          # noinspection RubySimplifyBooleanInspection
          return false == ret ? abort('Already locked') : block.call
        end
      end
    end
  end

  protected

  # @return [String]
  attr_reader :path

  # @return [String]
  def default_filepath
    "#{Sys::Proc.progname}/#{Digest::MD5.hexdigest(__FILE__)}.lock".tap do |fp|
      return Pathname.new(XDG['CACHE'].to_s).join(fp).to_s
    end
  end

  # @param [string] msg
  #
  # @raise [LockError]
  def abort(msg)
    raise LockError, msg
  end
end
