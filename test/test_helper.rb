# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dagger"

require "minitest/autorun"

require 'database_cleaner'

ActiveRecord::Base.configurations = {
  default_env: {
    url: ENV.fetch('DATABASE_URL', "sqlite3::memory:")
  }
}

# Configure ActiveRecord
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection

DatabaseCleaner.strategy = :truncation

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end

require_relative 'app/schema'
require_relative 'app/models'
