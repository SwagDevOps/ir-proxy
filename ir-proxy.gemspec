# frozen_string_literal: true

# vim: ai ts=2 sts=2 et sw=2 ft=ruby
# rubocop:disable all

Gem::Specification.new do |s|
  s.name        = "ir-proxy"
  s.version     = "1.0.2"
  s.date        = "2019-09-29"
  s.summary     = "Proxy for ir-keytable"
  s.description = "A simple proxy propagating event seen through ir-keytable"

  s.licenses    = ["GPL-3.0"]
  s.authors     = ["Dimitri Arrigoni"]
  s.email       = "dimitri@arrigoni.me"
  s.homepage    = "https://github.com/SwagDevOps/ir-proxy"

  s.required_ruby_version = ">= 2.5.0"
  s.require_paths = ["lib"]
  s.bindir        = "bin"
  s.executables   = [
    "ir-proxy",
  ]
  s.files         = [
    ".yardopts",
    "README.md",
    "bin/ir-proxy",
    "lib/ir_proxy.rb",
    "lib/ir_proxy/adapter.rb",
    "lib/ir_proxy/adapter/adapter.rb",
    "lib/ir_proxy/adapter/dummy.rb",
    "lib/ir_proxy/adapter/has_logger.rb",
    "lib/ir_proxy/adapter/xdotool.rb",
    "lib/ir_proxy/bundleable.rb",
    "lib/ir_proxy/cli.rb",
    "lib/ir_proxy/cli/command.rb",
    "lib/ir_proxy/cli/command/behavior.rb",
    "lib/ir_proxy/clock.rb",
    "lib/ir_proxy/config.rb",
    "lib/ir_proxy/config/defaults.rb",
    "lib/ir_proxy/config/file.rb",
    "lib/ir_proxy/container.rb",
    "lib/ir_proxy/events.rb",
    "lib/ir_proxy/events/dispatcher.rb",
    "lib/ir_proxy/events/has_logger.rb",
    "lib/ir_proxy/events/key_down.rb",
    "lib/ir_proxy/events/key_scan.rb",
    "lib/ir_proxy/events/line_incoming.rb",
    "lib/ir_proxy/events/listener.rb",
    "lib/ir_proxy/file_lock.rb",
    "lib/ir_proxy/key_scan.rb",
    "lib/ir_proxy/key_scan/throttleable.rb",
    "lib/ir_proxy/key_table.rb",
    "lib/ir_proxy/key_table/abort_error.rb",
    "lib/ir_proxy/key_table/keymaps/rc6_0.yml",
    "lib/ir_proxy/key_table/keymaps/rc6_mce.yml",
    "lib/ir_proxy/logger.rb",
    "lib/ir_proxy/pipe.rb",
    "lib/ir_proxy/pipe/stream.rb",
    "lib/ir_proxy/process_manager.rb",
    "lib/ir_proxy/process_manager/shell.rb",
    "lib/ir_proxy/process_manager/state.rb",
    "lib/ir_proxy/sampler.rb",
    "lib/ir_proxy/sampler/line.rb",
    "lib/ir_proxy/services.rb",
    "lib/ir_proxy/syntax_highlighter.rb",
    "lib/ir_proxy/throttler.rb",
    "lib/ir_proxy/version.rb",
    "lib/ir_proxy/version.yml",
  ]

  s.add_runtime_dependency("chrono_logger", ["~> 1.1"])
  s.add_runtime_dependency("concurrent-ruby", ["~> 1.1"])
  s.add_runtime_dependency("kamaze-version", ["~> 1.0"])
  s.add_runtime_dependency("rouge", ["~> 3.26"])
  s.add_runtime_dependency("stibium-bundled", ["~> 0.0.1", ">= 0.0.4"])
  s.add_runtime_dependency("sys-proc", ["~> 1.1"])
  s.add_runtime_dependency("thor", ["~> 0.20"])
  s.add_runtime_dependency("xdg", [">= 2.2", "< 3.0"])
end

# Local Variables:
# mode: ruby
# End:
