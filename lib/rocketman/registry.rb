require 'forwardable'

module Rocketman
  class Registry
    extend SingleForwardable

    @backend = case Rocketman.configuration.backend
               when :memory
                 require 'rocketman/adapters/memory'
                 Rocketman::Adapter::Memory.instance
               when :redis
                 require 'rocketman/adapters/redis'
                 Rocketman::Adapter::Redis.instance
               end

    def_delegators :@backend, :register_consumer, :register_event, :get_consumers_for, :event_exists?
  end
end
