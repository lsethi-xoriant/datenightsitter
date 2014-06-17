require "database_cleaner"

RSpec.configure do |config|
  DatabaseCleaner.strategy = :truncation

  config.before(:suite) do
    DatabaseCleaner.clean
  end

end