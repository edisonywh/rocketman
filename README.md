# Rocketman
![rocketman](./rocketman.jpg)
<sub>*yes, I know it says Starman on the image*</sub>
> *🎶 And I think it's gonna be a long long time 'Till touch down brings me round again to find 🎶*

Rocketman is a gem that introduces Pub-Sub mechanism within Ruby code.

As with all Pub-Sub mechanism, this greatly decouples your upstream producer and downstream consumer, allowing for scalability, and easier refactor when you decide to move Pub-Sub to a separate service.

Rocketman also works without Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rocketman'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rocketman

## Usage

Rocketman exposes two module, `Rocketman::Producer` and `Rocketman::Consumer`. They do exactly as what their name implies. All you need to do is `include Rocketman::Producer` and `extend Rocketman::Consumer` into your code.

#### Producer
Producer exposes one **instance** method to you: `:emit`. `:emit` takes in the event name and an optional payload and publishes it to the consumers. There's nothing more you need to do. The producer do not have to know who its consumers are.

```ruby
class Producer
  include Rocketman::Producer

  def hello_world
    emit :hello, payload: {"one" => 1, "two" => 2}
  end
end
```

Note that Producer emit events with threads that run in a thread pool. The default number of worker is 5, and the workers default to checking the job with a 3 seconds interval. You can tweak it to your liking like so:

```ruby
# config/initializers/rocketman.rb

Rocketman.configure do |config|
  config.worker_count = 10 # defaults to 5
  config.latency      = 1  # defaults to 3, unit is :seconds
end
```

#### Consumer
Consumer exposes a **class** method, `:on_event`. `:on_event` takes in the event name, and also an additional block, which gets executed whenever a message is received. If an additional `payload` is emitted along with the event, you can get access to it in the form of block argument.

```ruby
class Consumer
  extend Rocketman::Consumer

  on_event :hello do |payload|
    puts "I've received #{payload} here!"
    # => I've received {:payload=>{"one"=>1, "two"=>2}} here!
  end
end
```

Simple isn't it?

##### Consume events from external services

If you want to also consume events from external services, you're in luck (well, as long as you're using `Redis` anyway..)

Rocketman exposes a `Rocketman::Bridge`, which allows your Ruby code to start consuming events from Redis, **without any changes to your consumers**.

This works because `Bridge` will listen for events from those services on behalf of you, and then it'll push those events onto the internal `Registry`.

**This pattern is powerful because this means your consumers do not have to know where the events are coming from, as long as they're registed onto `Registry`.**

Right now, only `Redis` is supported. Assuming you have the `redis` gem installed, this is how you register a bridge.

```ruby
Rocketman::Bridge.construct(Redis.new)
```

That's all! Rocketman will translate the following

```
redis-cli> PUBLISH hello payload
```

to something understandable by your consumer, so a consumer only has to do:

```ruby
on_event :hello do |payload|
  puts payload
end
```

Notice how it behaves exactly the same as if the events did not come from Redis? :)

**NOTE**: You should always pass in a **new, dedicated** connection to `Redis` to `Bridge#construct`. This is because `redis.subscribe` will hog the whole Redis connection (not just Ruby process), so `Bridge` expects a dedicated connection for itself.

## Roadmap

Right now events are using a `fire-and-forget` mechanism, which is designed to not cause issue to producers. However, this also means that if a consumer fail to consume an event, it'll be lost forever. **Next thing on the roadmap is look into a retry strategy + persistence mechanism.**

Emitted events are also stored in memory in `Rocketman::Pool`, which means that there's a chance that you'll lose all emitted jobs. **Something to think about is to perhaps move the emitted events/job queue onto a persistent storage, like Redis for example.**

The interface could also probably be better defined, as one of the goal of Rocketman is to be the stepping stone before migrating off to a real, proper message queue/pub-sub mechanism like Kafka. **I want to revisit and think about how can we make that transition more seamless.**

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are **very welcomed** on GitHub at https://github.com/edisonywh/rocketman, but before a pull request is submitted, **please first open up an issue** for discussion.

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rocketman project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rocketman/blob/master/CODE_OF_CONDUCT.md).

## Why is it called Rocketman?

Uh.. well it's named after the song by Elton John, but really, it has nothing to do with an actual Rocketman.
