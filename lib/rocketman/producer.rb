module Rocketman
  module Producer
    def emit(event, payload = {})
      event = Rocketman::Event.new(event.to_sym, payload)
      Rocketman::Pool.instance.schedule { event.notify_consumers }
    end
  end
end
