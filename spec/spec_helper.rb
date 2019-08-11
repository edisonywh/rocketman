require "bundler/setup"
require "pry"
require "rocketman"
require "support/test_pool.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Swap it out to a stub implementation because Thread environment is hard to test
  Rocketman.send(:remove_const, "Pool")
  Rocketman::Pool = Rocketman::TestPool

  config.before(:each) do
    Singleton.__init__(Rocketman::Registry)
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
