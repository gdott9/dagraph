require 'rails/generators/active_record'

module Dagraph
  module Generators # :nodoc:
    class ModelGenerator < Rails::Generators::NamedBase # :nodoc:
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(number)
        ActiveRecord::Generators::Base.next_migration_number(number)
      end

      def add_dag_line_to_node_model
        inject_into_class "app/models/#{klass.model_name.singular}.rb", klass.to_s do
          "  has_directed_acyclic_graph\n"
        end
      end
      def create_edge_model_file
        create_file "app/models/#{dagraph.edges_class_name.underscore}.rb", <<~RUBY
          class #{dagraph.edges_class_name} < ApplicationRecord
          end
        RUBY
      end

      def create_migration_file
        migration_template 'create_edges.rb.erb', "db/migrate/create_#{migration_name}.rb"
      end

      private

      def migration_name
        dagraph.edges_class_name.underscore.pluralize
      end

      def migration_class_name
        "Create#{migration_name.camelize}"
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      def klass
        @klass ||= class_name.camelize.constantize
      end

      def dagraph
        @dagraph ||= Dagraph::NodeConfig.new(klass)
      end
    end
  end
end
