module Rocketman
  module Producer
    def emit(event, **payload)
      event = Rocketman::Event.new(event, payload)
      event.notify_consumers
    end
  end
end
