# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# @formatter:off
{
  'process_manager': -> { ProcessManager.new },
  'events_dispatcher': -> { Events::Dispatcher.new },
  'key_scanner': -> { KeyScan },
  'config': -> { Config.new.freeze },
  'lock': -> { FileLock.new },
  # events listeners ------------------------------------------------
  'events:line.incoming': -> { Events::LineIncoming.new },
  'events:key.down': -> { Events::KeyDown.new },
  # adapters --------------------------------------------------------
  'adapter': -> { Adapter.instance },
  'adapters:xdotool': -> { Adapter::Xdotool.new },
}
# @formatter:on
