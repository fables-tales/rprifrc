require "rprifrc/resource_change_block_runner"
require "rprifrc/process_manager"

module Rprifrc
  class Runner
    def initialize(args, process_manager)
      @args = args
      @process_manager = process_manager
    end

    def run
      while !interrupted do
        run_process
      end
    end

    private

    attr_reader :args, :interrupted, :process_manager

    def run_process
      process_manager.ensure_started

      t = Thread.new {
        ResourceChangeBlockRunner.new(resource).run(5) do
          process_manager.ensure_killed
        end
      }

      @interrupted = !process_manager.await

      t.kill
    end

    def resource
      args[0]
    end

    def process_to_invoke
      args[1..-1]
    end
  end
end
