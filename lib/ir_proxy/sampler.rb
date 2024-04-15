# frozen_string_literal: true

# Copyright (C) 2019-2024 Dimitri Arrigoni <dimitri@arrigoni.me>
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
class IrProxy::Sampler
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  # @formatter:off
  {
    Line: 'line'
  }.each { |s, fp| autoload(s, Pathname.new(__dir__).join("sampler/#{fp}")) }
  # @formatter:on

  def initialize
    @samples = make_samples
  end

  def sample
    samples.to_a.sample[1]
  end

  def call
    $stdout.sync = true

    loop { output(sample) }
  rescue Interrupt
    exit(0)
  end

  protected

  attr_reader :samples

  def output(lines, interval = 0.5)
    lines.each do |line|
      now.tap do |time|
        { time: time, timestamp: '%0.6f' % time.to_f }.tap do |vars|
          Line.new("<%= timestamp %>: #{line}", **vars).tap { |output| $stdout.puts(output) }

          $stdout.flush
        end
      end
    end
    sleep(interval)
  end

  # @return [Float]
  def now
    Process.clock_gettime(IrProxy::Clock::TYPE).to_f
  end

  # @return {Symbol => Array<String>}
  def make_samples
    Pathname.new(__dir__).join('sampler/samples').tap do |path|
      Dir.glob("#{path}/*.yml").map do |fp|
        [Pathname.new(fp).basename('.yml').to_s.to_sym,
         YAML.safe_load(Pathname.new(fp).read).lines]
      end.tap { |samples| return samples.to_h }
    end
  end
end
