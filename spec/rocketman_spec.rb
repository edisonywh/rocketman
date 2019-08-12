RSpec.describe Rocketman do
  describe "Producer" do
    before do
      Producer = Class.new

      Producer.class_eval do
        include Rocketman::Producer

        def produce
          emit :hello, test: true
        end
      end
    end

    after do
      class_cleaner(Producer)
    end

    it 'should register event when emitting' do
      expect { Producer.new.produce }.to change { Rocketman::Registry.event_exists?(:hello) }.from(false).to(true)
    end

    it 'should notify all downstream consumers' do
      acknowledged = 0

      ConsumerOne = Class.new
      ConsumerOne.class_eval do
        extend Rocketman::Consumer

        on_event :hello do
          acknowledged += 1
        end
      end

      ConsumerTwo = Class.new
      ConsumerTwo.class_eval do
        extend Rocketman::Consumer

        on_event :hello do
          acknowledged += 1
        end
      end

      expect { Producer.new.produce }.to change { acknowledged }.from(0).to(2)
    end
  end

  describe "Consumer" do
    after do
      class_cleaner(Consumer)
    end
    it "should register itself as consumer when implementing on_event" do
      Consumer = Class.new

      Consumer.class_eval do
        extend Rocketman::Consumer

        on_event :hello do
          nil
        end
      end

      expect(Rocketman::Registry.get_consumers_for(:hello).keys).to include Consumer
    end

    it "should run on_event when event is emitted" do
      Consumer = Class.new

      acknowledged = 0

      Consumer.class_eval do
        extend Rocketman::Consumer

        on_event :hello do
          acknowledged += 1
        end
      end

      Producer = Class.new
      Producer.class_eval do
        include Rocketman::Producer

        def produce
          emit :hello, test: true
        end
      end

      expect { Producer.new.produce }.to change { acknowledged }.from(0).to(1)
    end
  end

  # describe "Adapters" do
  #   before do
  #     Rocketman.configuration.backend = :redis
  #   end
  #   describe "Redis" do
  #     before do
  #       Producer = Class.new

  #       Producer.class_eval do
  #         include Rocketman::Producer

  #         def produce
  #           emit :hello, test: true
  #         end
  #       end
  #     end

  #     after do
  #       class_cleaner(Producer)
  #     end

  #     it 'should register event when emitting' do
  #       expect { Producer.new.produce }.to change { Rocketman::Registry.event_exists?(:hello) }.from(false).to(true)
  #     end

  #     it 'should notify all downstream consumers' do
  #       acknowledged = 0

  #       ConsumerOne = Class.new
  #       ConsumerOne.class_eval do
  #         extend Rocketman::Consumer

  #         on_event :hello do
  #           acknowledged += 1
  #         end
  #       end

  #       ConsumerTwo = Class.new
  #       ConsumerTwo.class_eval do
  #         extend Rocketman::Consumer

  #         on_event :hello do
  #           acknowledged += 1
  #         end
  #       end

  #       expect { Producer.new.produce }.to change { acknowledged }.from(0).to(2)
  #     end
  #   end
  # end

  private

  def class_cleaner(*klasses)
    klasses.each { |klass| Object.send(:remove_const, "#{klass}") if defined? klass }
  end
end
