require 'singleton'

module Rocketman
  class Pool
    include Singleton

    def initialize
      worker_count = 5 # TODO: Refactor to get from config
      latency = 3 # TODO: Refactor to get from config

      @latency = latency
      @jobs = Queue.new
      @workers = []

      worker_count.times do
        @workers << spawn_worker
      end

      # spawn_supervisor # TODO: Write a supervisor to monitor workers health, and restart if necessary
    end

    def schedule(&job)
      @jobs << job
    end

    private

    def spawn_worker
      Thread.new do
        loop do
          job = @jobs.pop
          job.call
          sleep @latency
        end
      end
    end
  end
end
