module Rocketman
  module Consumer
    def on_event(event, &action)
      consumer = self
      Rocketman::Registry.register_event(event)
      Rocketman::Registry.register_consumer(event, consumer, action)
    end
  end
end
