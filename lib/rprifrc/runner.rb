require "rprifrc/resource_change_block_runner"
require "rprifrc/process_manager"

module Rprifrc
  class Runner
    def initialize(args)
      @args = args
    end

    def run
      while !interrupted do
        run_process
      end
    end

    private

    attr_reader :args, :interrupted

    def run_process
      pm = ProcessManager.new(process_to_invoke)
      pm.ensure_started

      t = Thread.new {
        ResourceChangeBlockRunner.new(resource).run(5) do
          pm.ensure_killed
        end
      }

      @interrupted = !pm.await

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
