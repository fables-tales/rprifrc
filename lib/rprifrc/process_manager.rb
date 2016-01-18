module Rprifrc
  class ProcessManager
    def initialize(process_and_args)
      @process_and_args = process_and_args
      @process_handle = nil
    end

    def ensure_started
      if process_handle.nil? || !process_handle.status
        @stdin, @stdout, @stderr, @process_handle = Open3.popen3(*process_and_args)
      end
    end

    def await
      begin
        process_handle.value
        true
      rescue RuntimeError => e
        false
      ensure
        ensure_killed
      end
    end

    def ensure_killed
      if process_handle && process_handle.status
        Process.kill("TERM", process_handle.pid)
      end
    end

    private

    attr_reader :process_and_args, :process_handle
  end
end
