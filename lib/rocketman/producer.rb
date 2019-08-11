module Rocketman
  module Producer
    def emit(event, **payload)
      event = Rocketman::Event.new(event, payload)
      Rocketman::Pool.instance.schedule { event.notify_consumers }
    end
  end
end
