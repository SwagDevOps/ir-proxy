# frozen_string_literal: true

# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../behavior'

module IrProxy::Cli::Command::Behavior
  # Configurable appliables
  #
  # @see #on_start
  # @see .configurable_appliables
  #
  # @api private
  CONFIGURABLE_APPLIABLES = {
    config: {
      type: :string,
      desc: 'path to config file',
      default: IrProxy::Config.default_file.to_s,
    },
    adapter: {
      type: :string,
      desc: 'name of the adapter'
    },
    protocol: {
      type: :string,
      desc: 'name of the protocol',
    },
    logger: {
      type: :boolean,
      desc: 'enable logger',
    },
    repeat_delay: {
      type: :numeric,
      desc: 'keypress repetition interval (seconds)',
    },
  }.freeze
end
