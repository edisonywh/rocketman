require 'singleton'
require 'redis'

require 'pry'

module Rocketman
  module Adapter
    class Redis
      include Singleton

      REDIS_NAMESPACE = "rocketman_pubsub"

      def initialize
        @registry = ::Redis.new
      end

      def register_event(event)
        registry = get_registry

        if registry[event]
          return registry[event]
        else
          registry[event] = {}
          save_registry(registry)
        end
      end

      def register_consumer(event, consumer, action)
        registry = get_registry
        registry[event][consumer] = action
        save_registry(registry)
      end

      def get_consumers_for(event)
        registry = get_registry
        registry[event]
      end

      def event_exists?(event)
        registry = get_registry
        !registry[event].nil?
      end

      private

      def get_registry
        blob = @registry.get(REDIS_NAMESPACE)
        if blob
          Marshal.load(blob)
        else
          {}
        end
      end

      def save_registry(object)
        blob = Marshal.dump(object)
        @registry.set(REDIS_NAMESPACE, blob)
      end

      # def marshal(object)
      #   object.to_json
      # end

      # def unmarshal
      # end
    end
  end
end
