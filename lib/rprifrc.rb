require "open3"
require "http"
require "rprifrc/version"
require "rprifrc/runner"

module Rprifrc
  def self.main(args)
    return self.usage if args.length < 2
    Runner.new(args).run
  end

  def self.usage
    $stderr.puts("Usage: bundle exec rprifc https://user:password@some_resource process_to_invoke [with optional arguments]")
  end
end
