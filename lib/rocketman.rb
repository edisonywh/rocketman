require 'set'
require 'singleton'
require 'pry'

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

    def get_consumers_for(event)
      @registry[event]
    end

    def event_exists?(event)
      !@registry[event].nil?
    end
  end

  class Event
    def initialize(event, payload)
      @event = event
      @payload = payload
      @test = payload.fetch(:test, false)
      Rocketman::Registry.instance.register_event(event)
    end

    def notify_consumers
      consumers = Rocketman::Registry.instance.get_consumers_for(@event)

      threads = consumers.reduce([]) do |memo, (consumer, action)|
        memo << Thread.new { consumer.instance_exec(@payload, &action) }
      end

      threads.each { |t| t.join } if @test == true
    end
  end

  module Producer
    def self.included(base)
      base.include(InstanceMethods)
    end

    module InstanceMethods
      def emit(event, **payload)
        event = Rocketman::Event.new(event, payload)
        event.notify_consumers
      end
    end
  end

  module Consumer
    def self.included(base)
      base.extend(InstanceMethods)
    end

    module InstanceMethods
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
end
