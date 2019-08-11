module Rocketman
  def self.configuration
    @_configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :worker_count, :latency

    def initialize
      @worker_count = 5
      @latency = 3
    end
  end
end
