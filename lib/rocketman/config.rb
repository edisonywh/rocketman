module Rocketman
  def self.configuration
    @_configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :worker_count, :latency, :storage, :debug

    def initialize
      @worker_count = 5
      @latency = 3
      @storage= nil
      @debug = false
    end
  end
end
