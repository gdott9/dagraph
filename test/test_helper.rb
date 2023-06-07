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

ActiveRecord::Base.logger = Logger.new(STDOUT)

(1..7).each { |i| Node.create name: i }

NodeEdge.create(parent_id: 1, child_id: 2, hops: 0)
NodeEdge.create(parent_id: 1, child_id: 3, hops: 0)
NodeEdge.create(parent_id: 1, child_id: 3, hops: 0)
NodeEdge.create(parent_id: 2, child_id: 4, hops: 0)
NodeEdge.create(parent_id: 3, child_id: 4, hops: 0)
#
# NodeEdge.create(parent_id: 1, child_id: 2, hops: 0)
# NodeEdge.create(parent_id: 2, child_id: 3, hops: 0)
# NodeEdge.create(parent_id: 1, child_id: 3, hops: 0)
# NodeEdge.create(parent_id: 4, child_id: 2, hops: 0)
# NodeEdge.create(parent_id: 3, child_id: 5, hops: 0)
# NodeEdge.create(parent_id: 7, child_id: 6, hops: 0)
# NodeEdge.create(parent_id: 6, child_id: 3, hops: 0)
