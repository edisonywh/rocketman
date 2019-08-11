module Rocketman
  class TestPool
    def self.instance
      self
    end

    def self.schedule(&job)
      job.call
    end
  end
end
