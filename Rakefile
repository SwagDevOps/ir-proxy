# frozen_string_literal: true

require_relative 'lib/ir_proxy'
require 'ir_proxy'

require 'kamaze/project'
require 'sys/proc'

Sys::Proc.progname = nil

Kamaze.project do |project|
  project.subject = IrProxy
  project.name    = 'ir-proxy'
  project.tasks   = [
    'cs:correct', 'cs:control',
    'cs:pre-commit',
    'doc', 'doc:watch',
    'gem', 'gem:compile',
    'misc:gitignore',
    'shell', 'sources:license',
    'test',
  ]
end.load!

task default: [:gem]

if project.path('spec').directory?
  task :spec do |task, args|
    Rake::Task[:test].invoke(*args.to_a)
  end
end
