require "bundler/setup"
require "pry"
require "rocketman"
require "redis"
require "support/test_pool"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Swap it out to a stub implementation because Thread environment is hard to test
  Rocketman.send(:remove_const, "Pool")
  Rocketman::Pool = Rocketman::TestPool

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Rocketman.configure do |config|
  config.debug = true
end

def class_cleaner(*klasses)
  klasses.each { |klass| Object.send(:remove_const, "#{klass}") if defined? klass }
end
