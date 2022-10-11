# frozen_string_literal: true

# Copyright (C) 2019-2021 Dimitri Arrigoni <dimitri@arrigoni.me>
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

  def initialize(template, **variables)
    self.tap do
      @template = ERB.new(template)
      @context = Struct.new(*variables.keys).new(*variables.values).freeze
    end.freeze
  end

  # @return [String]
  def result
    template.result(context.instance_eval { binding })
  end

  alias to_s result

  protected

  # @return [ERB]
  attr_reader :template

  # @return [Struct]
  attr_reader :context
end
