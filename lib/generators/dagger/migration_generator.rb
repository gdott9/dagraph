require 'rails/generators/active_record'

module Dagger
  module Generators # :nodoc:
    class MigrationGenerator < Rails::Generators::NamedBase # :nodoc:
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(number)
        ActiveRecord::Generators::Base.next_migration_number(number)
      end

      def create_migration_file
        migration_template 'create_edges.rb.erb', "db/migrate/create_#{migration_name}.rb"
      end

      private

      def migration_name
        dagger.edges_class.table_name
      end

      def migration_class_name
        "Create#{migration_name.camelize}"
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def klass
        @klass ||= class_name.constantize
      end

      def dagger
        klass._dagger
      end
    end
  end
end
