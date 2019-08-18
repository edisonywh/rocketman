module Rocketman
  module Producer
    def emit(event, payload = {})
      event = Rocketman::Event.new(event.to_sym, payload)
      Rocketman::Pool.instance.jobs.schedule(event)
    end
  end
end
