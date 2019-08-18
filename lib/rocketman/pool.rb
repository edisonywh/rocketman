require 'singleton'
require 'rocketman/job_queue'

module Rocketman
  class Pool
    include Singleton

    attr_reader :jobs

    def initialize
      worker_count = Rocketman.configuration.worker_count
      latency = Rocketman.configuration.latency

      @latency = latency
      @jobs = Rocketman::JobQueue.new
      @workers = []

      worker_count.times do
        @workers << spawn_worker
      end

      # spawn_supervisor # TODO: Write a supervisor to monitor workers health, and restart if necessary
    end

    private

    def spawn_worker
      Thread.abort_on_exception = true if Rocketman.configuration.debug

      Thread.new do
        loop do
          job = @jobs.pop
          job.notify_consumers # Job is an instance of Rocketman::Event
          sleep @latency
        end
      end
    end
  end
end
