# frozen_string_literal: true

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
