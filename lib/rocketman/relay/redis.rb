require 'redis'

module Rocketman
  module Relay
    class Redis
      include Rocketman::Producer

      # You should always pass in a new, dedicated connection to `Redis`.
      # This is because `redis.psubscribe` will hog the whole Redis connection, thus if you pass in an existing Redis connection, you won't be able to do anything with that connection anymore.
      def start(service)
        puts "Rocketman> Using Redis as external producer".freeze if Rocketman.configuration.debug

        Thread.abort_on_exception = Rocketman.configuration.debug
        Thread.new do
          service.psubscribe("*") do |on|
            on.pmessage do |_pattern, event, payload|
              emit(event, payload)
            end
          end
        end
      end
    end
  end
end
