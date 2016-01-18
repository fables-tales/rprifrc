require "open3"
require "http"
require "rprifrc/version"

module Rprifrc
  def self.main(args)
    if args.length >= 2
      resource = args[0]
      process_to_invoke = args[1..-1]

      loop do
        stdin, stdout, stderr, process_handle = Open3.popen3(*process_to_invoke)
        t = nil
        begin
          t = Thread.new {
            last_response = HTTP.follow.get(resource).to_s
            loop {
              sleep(5)
              new_response = HTTP.follow.get(resource).to_s
              p "resp"
              p new_response != last_response
              if new_response != last_response
                Process.kill("TERM", process_handle.pid)
              end

              last_response = new_response

            }
          }

          process_handle.value
        rescue
          begin
            Process.kill("TERM", process_handle.pid)
          rescue
          end


          p "exception"
          p $!
          #TODO: log exception here
          break
        ensure
          p "kill"
          p t.kill
        end
      end
    else
      $stderr.puts("Usage: bundle exec rprifc https://user:password@some_resource process_to_invoke [with optional arguments]")
    end
  end
end
