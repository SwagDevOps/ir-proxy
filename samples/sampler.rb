#!/usr/bin/env ruby
# frozen_string_literal: true

# Print randomized samples
class Sampler
  autoload(:Pathname, 'pathname')
  autoload(:YAML, 'yaml')

  def initialize
    Pathname.new(__dir__).join('samples.yml').read.tap do |contents|
      @samples = YAML.safe_load(contents).freeze
    end
  end

  def sample
    samples.to_a.sample[1]
  end

  def call
    $stdout.sync = true
    loop do
      output(sample.lines)
    end
  rescue Interrupt
    exit(0)
  end

  protected

  attr_reader :samples

  def output(lines, duration = 0.1)
    lines.each do |line|
      $stdout.puts(line)
      $stdout.flush
      sleep(duration)
    end
  end
end

Sampler.new.tap(&:call) if __FILE__ == $PROGRAM_NAME
