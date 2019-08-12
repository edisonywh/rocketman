module Rocketman
  class Event
    def initialize(event, payload)
      @event = event
      @payload = payload
      @test = payload.fetch(:test, false)
      Rocketman::Registry.register_event(event)
    end

    def notify_consumers
      consumers = Rocketman::Registry.get_consumers_for(@event)

      consumers.each do |consumer, action|
        consumer.instance_exec(@payload, &action)
      end
    end
  end
end
