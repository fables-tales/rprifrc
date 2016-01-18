require "rprifrc/resource_change_block_runner"
require "rprifrc/process_manager"

module Rprifrc
  class Runner
    def initialize(args)
      @args = args
    end

    def run

      loop do
        pm = ProcessManager.new(process_to_invoke)

        pm.ensure_started

        t = Thread.new {
          ResourceChangeBlockRunner.new(resource).run(5) do
            pm.ensure_killed
          end
        }

        result = pm.await
        t.kill

        if !result
          break
        end
      end
    end

    private

    attr_reader :args

    def resource
      args[0]
    end

    def process_to_invoke
      args[1..-1]
    end
  end
end
