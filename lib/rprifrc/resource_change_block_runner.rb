module Rprifrc
  class ResourceChangeBlockRunner
    def initialize(resource)
      @resource = resource
    end

    def run(sleep, &blk)
      last_response = get_resource
      loop {
        sleep(sleep)
        new_response = get_resource
        if new_response != last_response
          blk.call
        end

        last_response = new_response

      }
    end

    private

    attr_reader :resource

    def get_resource
      HTTP.follow.get(resource).to_s
    end
  end
end
