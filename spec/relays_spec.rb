RSpec.describe "Relays" do
  describe "Redis" do
    before do
      require 'rocketman/relay/redis'
      Rocketman::Relay::Redis.new.start(Redis.new)
    end

    after do
      class_cleaner(Consumer)
    end

    context "when events are emitted from Redis" do
      it "should notify consumers" do
        Consumer = Class.new

        acknowledged = 0

        Consumer.class_eval do
          extend Rocketman::Consumer

          on_event :hello_from_redis do
            acknowledged += 1
          end
        end

        # BUG: Intermittent failure here due to race condition. This is because publish is an async request, it does not guarantee the event gets called in time
        expect { Redis.new.publish("hello_from_redis", {}.to_json); sleep 1 }.to change { acknowledged }.from(0).to(1)
      end
    end
  end
end
