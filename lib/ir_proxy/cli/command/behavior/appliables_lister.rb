# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

# List appliable options related to config.
#
# @see IrProxy::Cli::Command::Behavior.CONFIGURABLE_APPLIABLES
class IrProxy::Cli::Command::Behavior::AppliablesLister
  def initialize(appliables)
    @items = appliables.map { |key, value| [key, make_appliable(value, name: key)] }.to_h.freeze
  end

  def to_h
    items.dup
  end

  protected

  attr_reader :items

  def make_appliable(value, name:)
    IrProxy::Cli::Command::Behavior::Appliable.new(value, name: name)
  end
end
