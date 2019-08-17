module Rocketman
  class Bridge
    include Rocketman::Producer

    attr_reader :service

    def initialize(service)
      @service = service
    end

    def self.construct(service)
      instance = new(service)

      case instance.service.class.to_s
      when "Redis"
        puts "Rocketman> Using Redis as external producer".freeze
        Thread.new do
          instance.service.psubscribe("*") do |on|
            on.pmessage do |_pattern, event, payload|
              instance.emit(event, payload)
            end
          end
        end
      else
        puts "Rocketman> Don't know how to handle service: `#{service}`"
      end
    end
  end
end
