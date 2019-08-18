module Rocketman
  class TestPool
    def self.instance
      self
    end

    def self.jobs
      self
    end

    def self.schedule(job)
      job.notify_consumers
    end
  end
end
