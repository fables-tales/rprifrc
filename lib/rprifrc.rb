require "open3"
require "http"
require "rprifrc/version"
require "rprifrc/runner"

module Rprifrc
  def self.main(args)
    Runner.new(args).run
  end
end
