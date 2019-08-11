module Rocketman
  module Consumer
    def on_event(event, &action)
      consumer = self
      Rocketman::Registry.instance.register_event(event)
      register_consumer(event, consumer, action)
    end

    private

    def register_consumer(event, consumer, action)
      Rocketman::Registry.instance.register_consumer(event, consumer, action)
    end
  end
end
