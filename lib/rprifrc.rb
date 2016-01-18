require "open3"
require "http"
require "rprifrc/version"
require "rprifrc/runner"
require "rprifrc/process_manager"

module Rprifrc
  def self.main(args)
    return self.usage if args.length < 2

    rcbr = ResourceChangeBlockRunner.new(args[0])
    process_manager = ProcessManager.new(args[1..-1])

    Runner.new(rcbr, process_manager).run
  end

  def self.usage
    $stderr.puts("Usage: bundle exec rprifc https://user:password@some_resource process_to_invoke [with optional arguments]")
  end
end
