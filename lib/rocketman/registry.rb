require 'singleton'
require 'forwardable'

module Rocketman
  class Registry
    include Singleton

    def initialize
      @registry = {}
    end

    def register_event(event)
      if @registry[event]
        return @registry[event]
      else
        @registry[event] = {}
      end
    end

    def register_consumer(event, consumer, action)
      @registry[event][consumer] = action
    end

    def get_events
      @registry.keys
    end

    def get_consumers_for(event)
      @registry[event]
    end

    def event_exists?(event)
      !@registry[event].nil?
    end

    # This is to help hide the Singleton interface from the rest of the code
    class << self
      extend Forwardable
      def_delegators :instance, *Rocketman::Registry.instance_methods(false)
    end
  end
end
