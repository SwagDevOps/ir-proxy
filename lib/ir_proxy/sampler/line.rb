# frozen_string_literal: true

# Copyright (C) 2017-2019 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# Print randomized samples
#
# Simulate ouptut genereated by:
#
# ```sh
# sudo ir-keytable -a /etc/rc_maps.cfg -t
# ```
class IrProxy::Sampler::Line
  autoload(:ERB, 'erb')
  autoload(:OpenStruct, 'ostruct')

  def initialize(template, **variables)
    @template = ERB.new(template)
    @context = OpenStruct.new(**variables)
  end

  # @return [String]
  def result
    @template.result(@context.instance_eval { binding })
  end
end
