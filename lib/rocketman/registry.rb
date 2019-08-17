require 'forwardable'

module Rocketman
  class Registry
    extend SingleForwardable

    @backend = case Rocketman.configuration.backend
               when :memory
                 require 'rocketman/adapters/memory'
                 Rocketman::Adapter::Memory.instance
               end

    def_delegators :@backend, :register_consumer, :register_event, :get_consumers_for, :get_events, :event_exists?
  end
end
