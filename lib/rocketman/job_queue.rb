require 'forwardable'
require 'json'

module Rocketman
  class JobQueue
    extend Forwardable

    QUEUE_KEY = "rocketman".freeze

    def_delegators :@jobs, :<<, :empty?, :size, :clear, :push, :pop

    def initialize
      @storage = Rocketman.configuration.storage
      @jobs = get_job_queue

      at_exit { persist_events } if @storage.class.to_s == "Redis"
    end

    def schedule(job)
      @jobs << job
    end

    private

    def get_job_queue
      case @storage.class.to_s
      when "Redis"
        rehydrate_events
      else
        Queue.new
      end
    end

    def rehydrate_events
      queue = Queue.new

      if raw_data = @storage.get(QUEUE_KEY)
        puts "Rehydrating Rocketman events from #{@storage.class}" if Rocketman.configuration.debug

        rehydrate = JSON.restore(raw_data) # For security measure to prevent remote code execution (only allow contents valid in JSON)
        jobs = Marshal.load(rehydrate)
        event_count = 0

        until jobs.empty?
          queue << jobs.shift
          event_count += 1
        end

        puts "Rehydrated #{event_count} events from #{@storage.class}" if Rocketman.configuration.debug

        @storage.del(QUEUE_KEY) # After rehydration, delete it off Redis
      end

      queue
    end

    def persist_events
      return if @jobs.empty?

      puts "Persisting Rocketman events to #{@storage.class}" if Rocketman.configuration.debug
      intermediary = []
      event_count = 0

      until @jobs.empty?
        intermediary << @jobs.pop
        event_count += 1
      end
      @jobs.close

      marshalled_json = Marshal.dump(intermediary).to_json # For security measure to prevent remote code execution (only allow contents valid in JSON)

      @storage.set(QUEUE_KEY, marshalled_json)
      puts "Persisted #{event_count} events to #{@storage.class}" if Rocketman.configuration.debug
    end
  end
end
