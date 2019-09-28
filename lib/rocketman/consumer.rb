module Rocketman
  module Consumer
    def on_event(event, &action)
      consumer = self
      Rocketman::Registry.register_event(event)
      Rocketman::Registry.register_consumer(event, consumer, action)
    end

    def emit(event, payload = {})
      event = Rocketman::Event.new(event.to_sym, payload)
      Rocketman::Pool.instance.jobs.schedule(event)
    end
  end
end
