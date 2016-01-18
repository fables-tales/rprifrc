require "rprifrc/resource_change_block_runner"

module Rprifrc
  class Runner
    def initialize(args)
      @args = args
    end

    def run
      return usage if args.length < 2

      loop do
        stdin, stdout, stderr, process_handle = Open3.popen3(*process_to_invoke)
        t = nil
        begin
          t = Thread.new {
            ResourceChangeBlockRunner.new(resource).run(5) do
              Process.kill("TERM", process_handle.pid)
            end
          }

          process_handle.value
        rescue
          begin
            Process.kill("TERM", process_handle.pid)
          rescue
          end

          #TODO: log exception here
          break
        ensure
          t.kill
        end
      end
    end

    private

    attr_reader :args

    def usage
      $stderr.puts("Usage: bundle exec rprifc https://user:password@some_resource process_to_invoke [with optional arguments]")
    end

    def resource
      args[0]
    end

    def process_to_invoke
      args[1..-1]
    end
  end
end
