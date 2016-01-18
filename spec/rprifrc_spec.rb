require "spec_helper"
require "rprifrc"

RSpec.describe Rprifrc do
  describe ".main" do
    it "gives a usage message when it is provided with no arguments" do
      expect {
        Rprifrc.main([])
      }.to output("Usage: bundle exec rprifc https://user:password@some_resource process_to_invoke [with optional arguments]\n").to_stderr
    end

    it "does not give a usage message when it provided the correct arguments" do
      t = nil

      expect {
        t = Thread.new do
          Rprifrc.main(["https://httpbin.org/", "echo", ""])
        end

        sleep(2)
      }.not_to output.to_stderr

      t.kill
    end


    context "launching a python process" do
      before do
        @processes_before_test = get_count_of_python_processes
        @t = Thread.new do
          Rprifrc.main([resource] + process)
        end
      end

      after do
        sleep(0.25)
        @t.raise("fail")
        @t.join
        # Assert the process is killed after teardown
        expect(get_count_of_python_processes).to eq(@processes_before_test)
      end

      let(:resource) {
        "https://:sdfqwefqwefqwefqwefqwefwqf@limitless-retreat-5229.herokuapp.com/"
      }

      context "a process that lives forever" do
        let(:process) { ["python", "-c", "while True: pass"] }

        it "runs the process if both arguments are provided" do
          sleep(0.250)
          expect(get_count_of_python_processes).to be > @processes_before_test
        end

        context "with a changing resource" do
          let(:resource) {
            "https://gentle-tundra-5715.herokuapp.com/"
          }

          it "is restarted" do
            current_child_pid = `ps aux | grep -i python | grep -v grep`.split[1]
            sleep(7)
            new_child_pid = `ps aux | grep -i python | grep -v grep`.split[1]
            expect(current_child_pid != new_child_pid).to be true
          end
        end
      end

      context "a process that dies" do
        let(:process) { ["python", "-c", ""] }

        it "is restarted" do
          sleep(1)
          expect(get_count_of_python_processes).to be > @processes_before_test
        end
      end
    end
  end

  def get_count_of_python_processes
    `ps aux | grep -i 'python' | wc -l`.strip.to_i
  end
end
