# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# @formatter:off
{
  'process_manager': -> { ProcessManager.new },
  'event_dispatcher': -> { EventDispatcher.new },
  # events listeners ------------------------------------------------
  'events:line.incoming': -> { Events::LineIncoming.new },
  'events:key.down': -> { Events::KeyDown.new },
}
# @formatter:on
