module Rocketman
  class Event
    def initialize(event, payload)
      @event = event
      @payload = payload
      @test = payload.fetch(:test, false)
      Rocketman::Registry.instance.register_event(event)
    end

    def notify_consumers
      consumers = Rocketman::Registry.instance.get_consumers_for(@event)

      threads = consumers.reduce([]) do |memo, (consumer, action)|
        memo << Thread.new { consumer.instance_exec(@payload, &action) }
      end

      threads.each { |t| t.join } if @test == true
    end
  end
end
